require 'guid'
require 'eventmachine'
require 'mq'
require 'ostruct'

class JobsController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column if (Rails.env.production? || Rails.env.development?)
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

    # Support ATOM Format
    config.formats << :atom
  end

  # Restrict who can see what records in list view.
  # - Admins can see everything.
  # - Users in groups can see only those corresponding records along with records not in any group.
  # - Users not in a group can see only those corresponding records.
  def conditions_for_collection
    return [ 'jobs.group_id IS NULL' ] if current_user.nil?
    return [] if current_user.has_role?(:admin)
    groups = current_user.groups
    if (groups.size > 0)
      return [ '(jobs.group_id IN (?) OR jobs.group_id IS NULL)', groups.map!{|g| g.is_a?(Group) ? g.id : g} ]
    else
      return [ 'jobs.group_id IS NULL' ]
    end
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
    if (!params.key?(:input) || !params[:input].key?(:urls) || (params[:input][:urls].size <= 0))
      @record.valid?
      @record.errors.add("urls", "can't be blank")
      raise ActiveRecord::RecordInvalid.new(@record)
    end

    # Sanity Check.
    if (!params[:input].key?(:priority) || (params[:input][:priority].size <= 0))
      @record.valid?
      @record.errors.add("priority", "can't be blank")
      raise ActiveRecord::RecordInvalid.new(@record)
    end

    # Sanity Check.
    if (params[:input].key?(:wait))
      if (params[:input][:wait].size <= 0)
        @record.valid?
        @record.errors.add("wait", "can't be blank")
        raise ActiveRecord::RecordInvalid.new(@record)
      elsif (params[:input][:wait].to_i < Configuration.find_retry(:name => "url.wait.min", :namespace => "Job").to_i)
        @record.valid?
        @record.errors.add("wait", "can't be less than " + Configuration.find_retry(:name => "url.wait.min", :namespace => "Job").to_s)
        raise ActiveRecord::RecordInvalid.new(@record)
      elsif (params[:input][:wait].to_i > Configuration.find_retry(:name => "url.wait.max", :namespace => "Job").to_i)
        @record.valid?
        @record.errors.add("wait", "can't be greater than " + Configuration.find_retry(:name => "url.wait.max", :namespace => "Job").to_s)
        raise ActiveRecord::RecordInvalid.new(@record)
      end
    else
      params[:input][:wait] = Configuration.find_retry(:name => "url.wait", :namespace => "Job").to_s
    end

    # Sanity check.
    if (!params[:input].key?(:screenshot))
      params[:input][:screenshot] = Configuration.find_retry(:name => "url.screenshot", :namespace => "Job").to_s
      if params[:input][:screenshot] == "true"
        params[:input][:screenshot] = 1
      else
        params[:input][:screenshot] = 0
      end
    end

    # Sanity check.
    if (!params[:input].key?(:end_early))
      params[:input][:end_early] = Configuration.find_retry(:name => "url.end_early_if_load_complete", :namespace => "Job").to_s
      if params[:input][:end_early] == "true"
        params[:input][:end_early] = 1
      else
        params[:input][:end_early] = 0
      end
    end

    # Sanity check.
    if (!params[:input].key?(:reuse_browser))
      params[:input][:reuse_browser] = Configuration.find_retry(:name => "url.reuse_browser", :namespace => "Job").to_s
      if params[:input][:reuse_browser] == "true"
        params[:input][:reuse_browser] = 1
      else
        params[:input][:reuse_browser] = 0
      end
    end

    # Sanity check.
    if (!params[:input].key?(:always_fingerprint))
      params[:input][:always_fingerprint] = Configuration.find_retry(:name => "url.always_fingerprint", :namespace => "Job").to_s
      if params[:input][:always_fingerprint] == "true"
        params[:input][:always_fingerprint] = 1
      else
        params[:input][:always_fingerprint] = 0
      end
    end

    # Figure out if job_source was specified.
    if (params.key?(:input) &&
        params[:input].key?(:job_source) &&
        params[:input][:job_source].key?(:name) &&
        params[:input][:job_source].key?(:protocol))
      @record.job_source = JobSource.find_or_initialize_by_name_and_protocol_and_group_id(params[:input][:job_source][:name], params[:input][:job_source][:protocol], (current_user.groups.first.nil? ? nil : current_user.groups.first.id))
    else
      @record.job_source = JobSource.find_or_initialize_by_name_and_protocol_and_group_id(current_user.name, "https", (current_user.groups.first.nil? ? nil : current_user.groups.first.id))
    end

    # Collect the URLs.
    @record.urls = params[:input][:urls].split(' ').uniq.map!{|u| Url.new(:url                           => u,
                                                                          :priority                      => params[:input][:priority].to_i,
                                                                          :url_status                    => UrlStatus.find_by_status("queued"),
                                                                          :screenshot_id                 => params[:input][:screenshot].to_i,
                                                                          :wait_id                       => params[:input][:wait].to_i,
                                                                          :reuse_browser_id              => params[:input][:reuse_browser].to_i,
                                                                          :always_fingerprint_id         => params[:input][:always_fingerprint].to_i,
                                                                          :end_early_if_load_complete_id => params[:input][:end_early].to_i)}

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
      if (params[:input][:priority].to_i >= Configuration.find_retry(:name => "high_priority", :namespace => namespace).to_i)
        events_exchange.publish(@record.to_json(:include => {:job_alerts => {:except => :id}, :job_source => {:include => :group}, :urls => {:except => :id, :methods => [:wait_id, :reuse_browser_id, :always_fingerprint_id, :end_early_if_load_complete_id]}}), 
                                {:routing_key => Configuration.find_retry(:name => "high.routing_key",
                                 :namespace => "Job"),
                                :persistent => true})
      else
        events_exchange.publish(@record.to_json(:include => {:job_alerts => {:except => :id}, :job_source => {:include => :group}, :urls => {:except => :id, :methods => [:wait_id, :reuse_browser_id, :always_fingerprint_id, :end_early_if_load_complete_id]}}), 
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

  # Restrict who can see what records in list view.
  # - Admins can see everything.
  # - Users in groups can see only those corresponding records along with records not in any group.
  # - Users not in a group can see only those corresponding records.
  def conditions_for_url_collection
    return [ 'urls.group_id IS NULL' ] if current_user.nil?
    return [] if current_user.has_role?(:admin)
    groups = current_user.groups
    if (groups.size > 0)
      return [ '(urls.group_id IN (?) OR urls.group_id IS NULL)', groups.map!{|g| g.is_a?(Group) ? g.id : g} ]
    else
      return [ 'urls.group_id IS NULL' ]
    end
  end

  protected
  def list_respond_to_atom
    url_conditions = conditions_for_url_collection
    jobs = Job.find(:all, :select => 'DISTINCT jobs.*, urls.id AS url_id', :from => 'jobs', :joins => 'LEFT JOIN urls ON urls.job_id = jobs.id', :conditions => Job.merge_conditions(url_conditions, ['urls.url_status_id IN (?,?)', UrlStatus.find_by_status("suspicious").id, UrlStatus.find_by_status("compromised").id]), :order => 'urls.time_at DESC', :limit => Configuration.find_retry(:name => "atom.max_entries", :namespace => "Job").to_i)
    urls = Url.find(:all, :select => 'DISTINCT urls.*', :from => 'urls', :conditions => Url.merge_conditions(url_conditions, ['urls.url_status_id IN (?,?)', UrlStatus.find_by_status("suspicious").id, UrlStatus.find_by_status("compromised").id]), :order => 'urls.time_at DESC', :limit => Configuration.find_retry(:name => "atom.max_entries", :namespace => "Job").to_i)
    @data = jobs.zip(urls)

    if stale?(:last_modified => (@data.first.nil? ? Time.now.utc : Time.at(@data.first[1].time_at.to_f).utc), :etag => @data.first[1])
      respond_to do |format|
        format.atom
      end
    end
  end
end
