require 'guid'
require 'eventmachine'
require 'mq'

class JobsController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column
  before_filter :login_required

  active_scaffold :job do |config|
    # Table Title
    config.list.label = "Jobs"

    # Show the following columns in the specified order.
    config.list.columns = [:uuid, :created_at, :updated_at, :completed_at, :job_source, :job_alerts, :url_count]
    config.show.columns = [:uuid, :created_at, :updated_at, :completed_at, :job_source, :job_alerts, :url_count]

    # Sort columns in the following order.
    config.list.sorting = {:updated_at => :desc}

    # Rename the following columns.
    config.columns[:uuid].label = "ID"
    config.columns[:created_at].label = "Created"
    config.columns[:updated_at].label = "Updated"
    config.columns[:completed_at].label = "Completed"
    config.columns[:job_source].label = "Source"
    config.columns[:job_alerts].label = "Notifiers"
    config.columns[:url_count].label = "# URLs"

    # Make sure the job_source column is searchable.
    config.columns[:job_source].search_sql = 'job_sources.name'
    config.search.columns << :job_source

    # Make sure the job_alerts column is searchable.
    config.columns[:job_alerts].search_sql = "CONCAT(job_alerts.protocol, ':', job_alerts.address)"
    config.search.columns << :job_alerts

    # Disable eager loading.
    config.list.columns.exclude :urls

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "Job Details"

    # Include the following show actions.
    config.columns[:job_source].set_link :show, :controller => 'job_sources', :parameters => {:parent_controller => 'jobs'}

    # Show the associated links.
    config.columns[:job_alerts].actions_for_association_links = [:show]

    # Create settings.
    config.create.columns = [:urls]
    config.create.multipart = false
    config.create.persistent = false
    config.create.edit_after_create = false
  end

  def do_create
    # Create a blank job.
    if (current_user.nil?)
      @record = Job.new()
    else
      @record = Job.new(:uuid       => Guid.new.to_s,
                        :created_at => Time.now.utc,
                        :job_source => JobSource.find_or_create_by_name_and_protocol(current_user.name, "https"),
                        :job_alerts => [JobAlert.new(:protocol => "smtp", :address => current_user.email)])
    end


    # Sanity Check.
    if (!params.key?(:input) || !params[:input].key?(:urls))
      @record.valid?
      @record.errors.add("urls", "can't be blank")
      raise ActiveRecord::RecordInvalid.new(@record)
    end

    # Sanity Check.
    if !params[:input].key?(:priority)
      @record.valid?
      @record.errors.add("priority", "can't be blank")
      raise ActiveRecord::RecordInvalid.new(@record)
    end

    # Collect the URLs.
    @record.urls = params[:input][:urls].split(' ').map!{|u| Url.new(:url        => u,
                                                                     :priority   => params[:input][:priority].to_i,
                                                                     :url_status => UrlStatus.find_by_status("queued"))}

    # If the record is not valid, return an exception.
    if (!@record.valid?)
      @record.save!
    end

    # Send the Job.
    EM.run do
      # Declare the namespace.
      namespace = "collector"

      # Connect to the AMQP server.
      connection = AMQP.connect(:host    => Configuration.get(:name => "amqp.address", :namespace => namespace),
                                :user    => Configuration.get(:name => "amqp.user_name", :namespace => namespace),
                                :pass    => Configuration.get(:name => "amqp.password", :namespace => namespace),
                                :vhost   => Configuration.get(:name => "amqp.virtual_host", :namespace => namespace),
                                :logging => false)

      # Open a channel on the AMQP connection.
      channel = MQ.new(connection)

      # Declare/create the events exchange.
      events_exchange = MQ::Exchange.new(channel, :topic, Configuration.get(:name => "events_exchange_name", :namespace => namespace),
                                         {:passive     => false,
                                          :durable     => true,
                                          :auto_delete => false,
                                          :internal    => false,
                                          :nowait      => false})

      # Encode the message.
      # TODO: Figure out if using high or low routing key.
      events_exchange.publish(@record.to_json(:include => [:job_source, :job_alerts, :urls]), 
                              {:routing_key => Configuration.get(:name => "low.routing_key",
                               :namespace => "Job"),
                              :persistent => true})

      # Close the connection.
      connection.close { EM.stop }
    end
    flash.now[:info] = "Job submitted. Please refresh for updated listings."
    return @record
  end
end
