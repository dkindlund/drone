# Data Collector Daemon
#
# Used for populating the rails application with new data from the RabbitMQ server.

require 'rubygems'
require 'eventmachine'
require 'mq'
require 'pp'

class EventCollector

  # Class variables.
  @@allowed_actions    = [ "find_or_create",
                           "find_and_update",
                           "create" ]

  # Instance variables.
  @namespace           = nil

  # XXX: Possible deprecations.
  @connection          = nil
  @channel             = nil
  @events_exchange     = nil
  @commands_exchange   = nil
  @queue               = nil

  # XXX: Possible deprecation.
  # Upon initialization, attempt to connect to the AMQP server.
  # Note: This must be called inside an EM.run block.
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
  private :_setup

  # Gets all nested attributes that correspond to foreign keys in this object.
  def _get_nested_attributes(object)
    return object.attribute_names.find_all{|name| name =~ /.*_id$/}.map!{|str| str.gsub(/_id$/, '').to_sym} +
           object.attribute_names.find_all{|name| name =~ /.*_count$/}.map!{|str| str.gsub(/_count$/,'').pluralize.to_sym}
  end
  private :_get_nested_attributes

  # Recursively deletes all "_id", "id", "_count", and "updated_at" keys from the specified hash table.
  def _normalize(data)
    if data.kind_of?(Hash)
      data.delete_if{|key,value| key == "id" || key == "updated_at" || key =~ /.*_id$/ || key =~ /.*_count$/}
      data.each_value{|value| value = _normalize(value)}
    elsif data.kind_of?(Array)
      data.map!{|e| e = _normalize(e)}
    end 
    return data
  end
  # TODO: Enable this.
  #private :_normalize

  # Recursively finds or creates the nested object(s), based on the specified params.
  # Returns the nested object(s).
  # 
  # Corresponds to routing_key: object_name.find_or_create.*
  # 
  def _find_or_create(klass = nil, params = {}, args = [])

    # If we're given a hash, then recurse into each value.
    if params.kind_of?(Hash)

      # Recurse into each child and build out the corresponding child objects.
      params.each do |key,value|

        # Check the value.
        if value.kind_of?(Hash)

          # If the value is a hash, then the key is a singular class.
          child_klass = key.to_s.camelize.constantize

          # Update the child with the corresponding object.
          params[key] = _find_or_create(child_klass, value, args)

        elsif value.kind_of?(Array)

          # If the value is an array, then the key is a plural class.
          child_klass = key.to_s.camelize.singularize.constantize

          # TODO: Fix this - is this really what we want?
          # If we're given an array, then recurse into each element.
          value.map!{|p| _find_or_create(child_klass, p, args)}

        end
      end

      if not klass.nil?
        # Construct the parent object.

        # Search for valid attributes in params.
        attrs = {}
        klass.column_names.each do |attrib|
          # Skip unknown columns, and the id field.
          next if params[attrib].nil? || attrib == "id" 
          attrs[attrib] = params[attrib]
        end

        params = eval(klass.to_s + ".find_or_create_by_#{attrs.keys.join('_and_')}(params)")

        # If the object is still new or has changed, then force a save to generate an exception.
        if (params.new_record? || params.changed?)
          params.save!
        end

      end

    end
    # TODO: May want to output some sort of error message for non Hash types.

    # For all other data types, just return what was given.
    return params
  end
  # TODO: Enable this.
  #private :_find_or_create

  # Finds the corresponding object and updates the object, based upon the specified array of args.
  # 
  # Corresponds to routing_key: object_name.find_and_update.arg[0].arg[1]...
  # 
  def _find_and_update(klass = nil, params = {}, args = [])

    # Only operate on hashes that have a single key.
    if (params.kind_of?(Hash) && (params.keys.size == 1))
      object_name = params.keys.first.to_s
      klass = object_name.camelize.constantize

      # Find the existing entry; use an "id" if found (from recursive calls).
      if (params[object_name].key?("id"))
        # TODO: Delete this, eventually.
        puts "--- ID FOUND! = " + params[object_name]["id"].to_s
        object = klass.find(params[object_name]["id"].to_i)
      else
     
        # Search for valid attributes in params. 
        attrs = {}
        klass.column_names.each do |attrib|
          # Skip unknown and update columns, and the id field.
          next if params[object_name][attrib].nil? || attrib == "id" || !args.rindex(attrib.gsub('/_id$/','')).nil?
          attrs[attrib] = params[object_name][attrib]
        end

        # XXX: We assume Hash.keys and Hash.values return the same relative data, in order.
        object = eval(klass.to_s + ".find_by_#{attrs.keys.join('_and_')}(\"#{attrs.values.join('","')}\")")

        # Sanity check: Make sure we have an object at this point.
        if not object.kind_of?(klass)
          # TODO: May want to output some sort of error message.
          return params
        end

      end

      # TODO: Delete this, eventually
      #pp object

      args.each do |update_attrib|

        # Skip any undefined attributes.
        next if !params[object_name].key?(update_attrib)

        # Figure out what type of updated attribute this is.
        if (params[object_name][update_attrib].kind_of?(Hash))
          # If it's a hash, then we need to resolve the attribute to a corresponding object. 
          eval("object.#{update_attrib} = _find_or_create(update_attrib.camelize.constantize, params[object_name][update_attrib], [])")

        elsif (params[object_name][update_attrib].kind_of?(Array))

          # Iterate through each entry in the array.
          array = eval("object.#{update_attrib}")
          array.each do |entry|
            params[object_name][update_attrib].each do |update_hash|

              # Make sure the update entry is a hash.
              next if !update_hash.kind_of?(Hash)

              # Find the existing entry.
              # Obtain only the update hash entries that we're searching on.
              filter_array = update_hash.clone.delete_if{|key,value| !args.rindex(key).nil?}.to_a

              # Figure out if our entry contains all the matching attributes.
              match = entry.attributes.to_a & filter_array

              # If the intersection size is the same, then we assume this entry is our match.
              if (filter_array.size == match.size)
                update_hash["id"] = entry.id
                # Update the existing entry.
                _find_and_update(nil, {update_attrib.singularize => update_hash}, args)
                entry.reload
              end
            end
          end

        else
          # For all other types, assume it's just a primitive.
          eval("object.#{update_attrib} = params[object_name][update_attrib]")
        end
      end

      # Update the object.
      object.save!

      # TODO: Delete this, eventually
      #pp object

      params[object_name] = object
    end
    # TODO: May want to output some sort of error message for non Hash types.

    # For all other data types, just return what was given.
    return params
  end
  # TODO: Enable this.
  #private :_find_and_update

  # Creates the corresponding object and tries to reuse as many predeclared sub-objects as possible.
  # Only attributes specified in args will be (potentially) duplicated; all other attributes will be
  # reused.
  # 
  # Corresponds to routing_key: object_name.create.arg[0].arg[1]...
  # 
  def _create(klass = nil, params = {}, args = [])

    # If we're given a hash, then recurse into each value.
    if params.kind_of?(Hash)

      # Recurse into each child and build out the corresponding child objects.
      params.each do |key,value|

        # Check the value.
        if value.kind_of?(Hash)

          # If the value is a hash, then the key is a singular class.
          child_klass = key.to_s.camelize.constantize

          # Update the child with the corresponding object.
          params[key] = _create(child_klass, value, args)

        elsif value.kind_of?(Array)

          # If the value is an array, then the key is a plural class.
          child_klass = key.to_s.singularize.camelize.constantize

          # TODO: Fix this - is this really what we want?
          # If we're given an array, then recurse into each element.
          value.map!{|p| _create(child_klass, p, args)}

        end
      end

      if not klass.nil?
        # Construct the parent object.

        # Figure out if we create from scratch or if we try and reuse an identical object.
        if (!args.rindex(klass.to_s.tableize).nil? ||
            !args.rindex(klass.to_s.tableize.singularize).nil?)

          # Create the specified params from scratch.
          params = klass.create(params)

        else
          # Search for valid attributes in params.
          attrs = {}
          klass.column_names.each do |attrib|
            # Skip unknown columns, and the id field.
            next if params[attrib].nil? || attrib == "id" 
            attrs[attrib] = params[attrib]
          end

          params = eval(klass.to_s + ".find_or_create_by_#{attrs.keys.join('_and_')}(params)")

        end

        # If the object is still new or has changed, then force a save to generate an exception.
        if (params.new_record? || params.changed?)
          params.save!
        end
      end
    end
    # TODO: May want to output some sort of error message for non Hash types.

    # For all other data types, just return what was given.
    return params

  end
  # TODO: Enable this.
  #private :_create

  # Process the specified event.
  def _process_event(header, msg)
    hash = ActiveSupport::JSON.decode(msg)

    # Sanity check the message.
    if not hash.kind_of?(Hash)
      raise "Invalid message type: " + hash.class.to_s
    end

    # TODO: Make sure we not removing too much information.
    hash = _normalize(hash)

    # TODO: Delete this, eventually.
    #puts "Input:"
    #pp hash

    # Decode the key.
    array = header.properties[:routing_key].split('.')
    object_name = array[0]
    action = array[1]

    # Sanity check the action.
    if (@@allowed_actions.rindex(action).nil?)
      raise "Invalid action: " + action.to_s
    end

    args = array.values_at(2..-1) 
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

  # XXX: Possible deprecation.
  # Starts the daemon.
  def start
    EM.run do
      _setup()

      RAILS_DEFAULT_LOGGER.info "Starting Event Collector Daemon [PID: " + Process.pid.to_s + "]"

      # Declare the queue on the channel.
      @queue = MQ::Queue.new(@channel, Configuration.get(:name => 'queue_name', :namespace => @namespace), 
                             {:passive     => false,
                              :durable     => true,
                              :exclusive   => false,
                              :auto_delete => false,
                              :nowait      => false})

    
      # Bind the queue to the exchanges.
      @queue.bind(@events_exchange, :key => Configuration.get(:name => 'events_routing_key', :namespace => @namespace))
      @queue.bind(@commands_exchange, :key => Configuration.get(:name => 'commands_routing_key', :namespace => @namespace))
      
      # Subscribe to the messages in the queue.
      @queue.subscribe(:ack => true, :nowait => false) do |header, msg|
  
        # Process message.
        # TODO: Delete this, eventually.
        #pp [:got, header, msg]

        begin 
          msg = eval("_process_" + header.properties[:exchange].to_s.downcase.singularize + "(header, msg)")
        rescue
          RAILS_DEFAULT_LOGGER.warn $!.to_s
          puts $!.to_s
        end
 
        # ACK receipt of message.
        header.ack()

        # Check if we were given the shutdown command.
        if ((header.properties[:exchange] == "commands") &&
            (header.properties[:routing_key] == "drone." + @namespace.to_s) &&
            (msg == "shutdown"))

          RAILS_DEFAULT_LOGGER.info "Stopping Event Collector Daemon [PID: " + Process.pid.to_s + "]"

          # Close the connection.
          #@connection.close{ EM.stop_event_loop }
          #@connection.close{ EM.stop }
          #AMQP.stop { @connection.close; EM.stop }
#puts "Sleeping 10s..."
#sleep 10
          EM.next_tick { @connection.close{ EM.stop_event_loop } }
        end
  
      end
  
    end
  end

  # XXX: Possible deprecation.
  # Stops the daemon.
  def stop
    EM.run do
      _setup()

      # Publish the message to the exchange.
      message = "shutdown".to_json
      @commands_exchange.publish(message, {:routing_key => 'drone.' + @namespace.to_s, :persistent => true})

      # Close the connection.
      @connection.close{ EM.stop }
    end
  end

  # XXX: Possible deprecation.
  # Send events to the collector, in the form of one or more objects.
  def send(routing_key, object)
    EM.run do
      _setup()

      # Publish the object(s) to the exchange.
      if object.kind_of?(Hash)
        @events_exchange.publish(object.to_json(), {:routing_key => routing_key.to_s, :persistent => true})
      elsif object.kind_of?(Array)
        object.each do |o|
          @events_exchange.publish(o.to_json(:include => _get_nested_attributes(o)), {:routing_key => routing_key.to_s, :persistent => true})
        end
      else
        @events_exchange.publish(object.to_json(:include => _get_nested_attributes(object)), {:routing_key => routing_key.to_s, :persistent => true})
      end

      # Close the connection.
      @connection.close{ EM.stop }
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

