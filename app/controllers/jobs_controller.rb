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

    # Figure out if job_source was specified.
    if (params.key?(:input) &&
        params[:input].key?(:job_source) &&
        params[:input][:job_source].key?(:name) &&
        params[:input][:job_source].key?(:protocol))
      @record.job_source = JobSource.find_or_create_by_name_and_protocol(params[:input][:job_source][:name], params[:input][:job_source][:protocol])
    else
      @record.job_source = JobSource.find_or_create_by_name_and_protocol(current_user.name, "https")
    end

    # Collect the URLs.
    @record.urls = params[:input][:urls].split(' ').map!{|u| Url.new(:url        => u,
                                                                     :priority   => params[:input][:priority].to_i,
                                                                     :url_status => UrlStatus.find_by_status("queued"))}

    # Manually update the URL count.
    @record.url_count = @record.urls.size

    # If the record is not valid, return an exception.
    if (!@record.valid?)
      @record.save!
    end

    # Send the Job.
    EM.run do
      # Declare the namespace.
      namespace = "collector"

      # Connect to the AMQP server.
      connection = AMQP.connect(:host    => Configuration.find_retry(:name => "amqp.address", :namespace => namespace),
                                :user    => Configuration.find_retry(:name => "amqp.user_name", :namespace => namespace),
                                :pass    => Configuration.find_retry(:name => "amqp.password", :namespace => namespace),
                                :vhost   => Configuration.find_retry(:name => "amqp.virtual_host", :namespace => namespace),
                                :logging => false)

      # Open a channel on the AMQP connection.
      channel = MQ.new(connection)

      # Declare/create the events exchange.
      events_exchange = MQ::Exchange.new(channel, :topic, Configuration.find_retry(:name => "events_exchange_name", :namespace => namespace),
                                         {:passive     => false,
                                          :durable     => true,
                                          :auto_delete => false,
                                          :internal    => false,
                                          :nowait      => false})

      # Encode the message.
      # TODO: Figure out if using high or low routing key.
      if (params[:input][:priority].to_i >= Configuration.find_retry(:name => "high_priority", :namespace => namespace).to_i)
        events_exchange.publish(@record.to_json(:include => [:job_source, :job_alerts, :urls]), 
                                {:routing_key => Configuration.find_retry(:name => "high.routing_key",
                                 :namespace => "Job"),
                                :persistent => true})
      else
        events_exchange.publish(@record.to_json(:include => [:job_source, :job_alerts, :urls]), 
                                {:routing_key => Configuration.find_retry(:name => "low.routing_key",
                                 :namespace => "Job"),
                                :persistent => true})
      end

      # Close the connection.
      connection.close { EM.stop }
    end

    # Refresh the job.
    # XXX: This works great as long as there is not a backlog in the queue.
    # Then, this will loop for a long period of time a not return feedback to the user.
    #new_job = Job.find_by_uuid(@record.uuid.to_s)
    #while (new_job.nil?)
    #  new_job = Job.find_by_uuid(@record.uuid.to_s)
    #  sleep 1
    #end
    #new_job.expire_caches
    #@record = new_job

    flash.now[:info] = "Job submitted. Please refresh before viewing job details.  If the job does not appear shortly after refresh, then resubmit with a higher priority (e.g., >= " + Configuration.find_retry(:name => "high_priority", :namespace => "collector").to_s + ")."
    return @record
  end
end
