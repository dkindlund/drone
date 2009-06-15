# Event Notifier Daemon
#
# Used for notifying users when jobs are complete.

require 'rubygems'
require 'action_mailer'
require 'eventmachine'
require 'mq'
require 'pp'
require 'daemonize'

class EventNotifier
  include DaemonizeHelper

  # Class variables.
  @@allowed_actions    = [ "find_and_update",
                           "create" ]

  # Instance variables.
  @namespace           = nil
  @connection          = nil
  @channel             = nil
  @events_exchange     = nil
  @commands_exchange   = nil
  @queue               = nil

  # Upon initialization, attempt to connect to the AMQP server.
  # Note: This must be called inside an EM.run block.
  def _setup
    # Declare the namespace.
    # Switch to the 'collector' namespace, in order to reuse AMQP server settings.
    @namespace = "collector"

    # Connect to the AMQP server.
    @connection = AMQP.connect(:host    => Configuration.find_retry(:name => 'amqp.address',      :namespace => @namespace),
                               :user    => Configuration.find_retry(:name => 'amqp.user_name',    :namespace => @namespace),
                               :pass    => Configuration.find_retry(:name => 'amqp.password',     :namespace => @namespace),
                               :vhost   => Configuration.find_retry(:name => 'amqp.virtual_host', :namespace => @namespace),
                               :logging => false)

    # Open a channel on the AMQP connection.
    @channel = MQ.new(@connection)

    # Declare/create the events exchange.
    @events_exchange = MQ::Exchange.new(@channel, :topic, Configuration.find_retry(:name      => 'events_exchange_name',
                                                                            :namespace => @namespace),
                                 {:passive     => false,
                                  :durable     => true,
                                  :auto_delete => false,
                                  :internal    => false,
                                  :nowait      => false})

    # Declare/create the commands exchange.
    @commands_exchange = MQ::Exchange.new(@channel, :topic, Configuration.find_retry(:name      => 'commands_exchange_name',
                                                                              :namespace => @namespace),
                                 {:passive     => false,
                                  :durable     => true,
                                  :auto_delete => false,
                                  :internal    => false,
                                  :nowait      => false})

    # Now, switch back to the 'notifier' namespace, for all other configuration settings.
    @namespace = "notifier"
  end
  private :_setup

  # Sends email notification upon job completion.
  def _find_and_update(klass = nil, params = {}, args = [])

    # Sanity checks.
    if (!params.kind_of?(Hash) ||
        !params.key?("job") ||
        !params["job"].key?("job_alerts") ||
        (params["job"]["job_alerts"].size <= 0))
        return
    end 

    params["job"]["recipients"] = []
    params["job"]["job_alerts"].each do |job_alert|
      if (job_alert.kind_of?(Hash) &&
          job_alert.key?("protocol") &&
          (job_alert["protocol"].to_s == "smtp") &&
          job_alert.key?("address") &&
          (job_alert["address"].size > 0))
        params["job"]["recipients"] << job_alert["address"].to_s 
      end
    end

    if (params["job"]["recipients"].size > 0)
      JobMailer.deliver_job_completed(params["job"])
    end
  end
  private :_find_and_update

  # Sends email notification upon job creation.
  def _create(klass = nil, params = {}, args = [])

    # Sanity checks.
    if (!params.kind_of?(Hash) ||
        !params.key?("job") ||
        !params["job"].key?("job_alerts") ||
        (params["job"]["job_alerts"].size <= 0))
        return
    end 

    params["job"]["recipients"] = []
    params["job"]["job_alerts"].each do |job_alert|
      if (job_alert.kind_of?(Hash) &&
          job_alert.key?("protocol") &&
          (job_alert["protocol"].to_s == "smtp") &&
          job_alert.key?("address") &&
          (job_alert["address"].size > 0))
        params["job"]["recipients"] << job_alert["address"].to_s 
      end
    end

    if (params["job"]["recipients"].size > 0)
      JobMailer.deliver_job_created(params["job"])
    end
  end
  private :_create

  # Process the specified event.
  def _process_event(header, msg)
    hash = ActiveSupport::JSON.decode(msg)

    # Sanity check the message.
    if not hash.kind_of?(Hash)
      raise "Invalid message type: " + hash.class.to_s
    end

    # Decode the key.
    array = header.properties[:routing_key].split('.')

    # Figure out if a priority was supplied as the first
    # entry.
    if ((Integer(array[0]) rescue false) == false)
      # No priority found.
      object_name = array[0]
      action = array[1]
      remainder_index = 2
    else
      # Priority found.
      object_name = array[1]
      action = array[2]
      remainder_index = 3
    end

    # Sanity check the action.
    if (@@allowed_actions.rindex(action).nil?)
      raise "Invalid action: " + action.to_s
    end

    args = array.values_at(remainder_index..-1) 
    eval("_" + action.to_s + "(nil, hash, args)")

    # TODO: Delete this, eventually.
    #puts "Output:"
    pp hash

    return hash
  end
  private :_process_event

  # Process the specified command.
  def _process_command(header, msg)
    return ActiveSupport::JSON.decode(msg)
  end
  private :_process_command

  # Starts the daemon.
  def start(detach=false)
    EM.run do

      # Daemonize the process if flag is set.
      daemonize if detach

      _setup()

      RAILS_DEFAULT_LOGGER.info "Starting Event Notifier Daemon [PID: " + Process.pid.to_s + "]"

      # Declare the queue on the channel.
      @queue = MQ::Queue.new(@channel, Configuration.find_retry(:name => 'queue_name', :namespace => @namespace), 
                             {:passive     => false,
                              :durable     => true,
                              :exclusive   => false,
                              :auto_delete => false,
                              :nowait      => false})

    
      # Bind the queue to the exchanges.
      @queue.bind(@commands_exchange, :key => Configuration.find_retry(:name => 'commands_routing_key', :namespace => @namespace))
      events_routing_keys = Configuration.find_retry(:name => 'events_routing_key', :namespace => @namespace).split(';')
      events_routing_keys.each do |events_routing_key|
        @queue.bind(@events_exchange, :key => events_routing_key)
      end
     
      shutdown = false 
      # Subscribe to the messages in the queue.
      @queue.subscribe(:ack => true, :nowait => false) do |header, msg|
 
        unless shutdown 
          # Process message.
          # TODO: Delete this, eventually.
          #pp [:got, header, msg]

          begin 
            msg = eval("_process_" + header.properties[:exchange].to_s.downcase.singularize + "(header, msg)")
          rescue Memcached::SystemError, Memcached::ServerIsMarkedDead, Memcached::UnknownReadFailure, Memcached::ATimeoutOccurred
            # If our memcached server goes away, then retry.
            RAILS_DEFAULT_LOGGER.warn $!.to_s
            puts "Retrying Event - " + $!.to_s
            retry
          rescue
            # Otherwise, log the error and discard the event.
            RAILS_DEFAULT_LOGGER.warn $!.to_s
            pp $!
          end
 
          # ACK receipt of message.
          header.ack()
        end

        # Check if we were given the shutdown command.
        if ((header.properties[:exchange] == "commands") &&
            (header.properties[:routing_key] == @namespace.to_s) &&
            (msg == "shutdown"))

          RAILS_DEFAULT_LOGGER.info "Stopping Event Notifier Daemon [PID: " + Process.pid.to_s + "]"
          shutdown = true
          EM.next_tick { @connection.close{ EM.stop_event_loop } }
        end
  
      end
  
    end
  end

  # Stops the daemon.
  def stop(detach=false)
    if detach
      # Kill PID, if daemonized.
      stop_daemon
    else
      EM.run do
        _setup()

        # Publish the message to the exchange.
        message = "shutdown".to_json
        @commands_exchange.publish(message, {:routing_key => @namespace.to_s, :persistent => true})

        # Close the connection.
        @connection.close{ EM.stop }
      end
    end
  end

  class TestHeader
    attr_accessor :properties
  end

  # Pretend to send the events to the collector (for integration testing).
  def test_send_event(routing_key, object)
    if object.kind_of?(Hash)
      message = object.to_json()
      header = TestHeader.new
      header.properties = {
        :routing_key => routing_key
      }
      return _process_event(header, message)
    end
  end
end

