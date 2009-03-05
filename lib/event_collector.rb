# Data Collector Daemon
#
# Used for populating the rails application with new data from the RabbitMQ server.

require 'rubygems'
require 'eventmachine'
require 'mq'
require 'pp'

class EventCollector

  # Class variables.
  @namespace           = nil
  @connection          = nil
  @channel             = nil
  @events_exchange     = nil
  @commands_exchange   = nil

  # Upon initialization, attempt to connect to the AMQP server.
  def _setup
    # Declare the namespace.
    @namespace = "collector"

    # Connect to the AMQP server.
    @connection = AMQP.connect(:host    => Configuration.get(:name => 'amqp.address',      :namespace => @namespace),
                               :user    => Configuration.get(:name => 'amqp.user_name',    :namespace => @namespace),
                               :pass    => Configuration.get(:name => 'amqp.password',     :namespace => @namespace),
                               :vhost   => Configuration.get(:name => 'amqp.virtual_host', :namespace => @namespace),
                               :logging => false)
  
    # Open a channel on the AMQP connection.
    @channel = MQ.new(@connection)

    # Declare/create the events exchange.
    @events_exchange = MQ::Exchange.new(@channel, :topic, Configuration.get(:name      => 'events_exchange_name',
                                                                            :namespace => @namespace),
                                 {:passive     => false,
                                  :durable     => true,
                                  :auto_delete => false,
                                  :internal    => false,
                                  :nowait      => false})

    # Declare/create the commands exchange.
    @commands_exchange = MQ::Exchange.new(@channel, :topic, Configuration.get(:name      => 'commands_exchange_name',
                                                                              :namespace => @namespace),
                                 {:passive     => false,
                                  :durable     => true,
                                  :auto_delete => false,
                                  :internal    => false,
                                  :nowait      => false})
  end

  # Starts the daemon.
  def start
    EM.run do
      _setup()

      # Declare the queue on the channel.
      queue = MQ::Queue.new(@channel, Configuration.get(:name => 'queue_name', :namespace => @namespace), 
                            {:passive     => false,
                             :durable     => true,
                             :exclusive   => false,
                             :auto_delete => false,
                             :nowait      => false})

    
      # Bind the queue to the exchanges.
      queue.bind(@events_exchange, :key => Configuration.get(:name => 'events_routing_key', :namespace => @namespace))
      queue.bind(@commands_exchange, :key => Configuration.get(:name => 'commands_routing_key', :namespace => @namespace))
      
      # Subscribe to the messages in the queue.
      queue.subscribe(:ack => true, :nowait => false) do |header, msg|
  
        # Process message.
        pp [:got, header, msg]
        pp ActiveSupport::JSON.decode(msg)
 
        # ACK receipt of message.
        header.ack()

        # Check if we were given the shutdown command.
        if ((header.properties[:exchange] == "commands") &&
            (header.properties[:routing_key] == "drone." + @namespace.to_s) &&
            (msg == "shutdown"))

          # Close the connection.
          @connection.close{ EM.stop_event_loop }
        end
  
      end
  
    end
  end

  # Stops the daemon.
  def stop
    EM.run do
      _setup()

      # Publish the message to the exchange.
      message = "shutdown".to_json
      @commands_exchange.publish(message, {:routing_key => 'drone.' + @namespace.to_s, :persistent => true})

      # Close the connection.
      @connection.close{ EM.stop_event_loop }
  
    end
  end

  # Generates test messages.
  def test
    EM.run do
      _setup()

      # Publish a message to the exchange.
      string = Client.find(:first).to_json
      @events_exchange.publish(string, {:routing_key => 'foo', :persistent => true})

      # Close the connection.
      @connection.close{ EM.stop_event_loop }
  
    end
  end

end

