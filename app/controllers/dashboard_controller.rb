class DashboardController < ApplicationController
  ssl_required :index if (Rails.env.production? || Rails.env.development?)
  ssl_allowed :url_queue_size if (Rails.env.production? || Rails.env.development?)
  ssl_allowed :running_vms_count if (Rails.env.production? || Rails.env.development?)
  before_filter :login_required

  def index
    # TODO: Update timeline to include dynamic AJAX updates.
    # Timeline UI
    @timeline_width = Configuration.find_retry(:name => "ui.url_stats_timeline.width", :namespace => "UrlStatistic")
    @timeline_height = Configuration.find_retry(:name => "ui.url_stats_timeline.height", :namespace => "UrlStatistic")
    @timeline_data = {}
    @annotations = {}
    timeline_display_age = Configuration.find_retry(:name => "ui.display.age", :namespace => "UrlStatistic")
    url_statistics = UrlStatistic.find(:all, :conditions => ["url_statistics.created_at >= ?", eval(timeline_display_age + ".ago")], :order => "url_statistics.created_at ASC")

    url_statuses = UrlStatus.find(:all)
    url_status_lookup = {}
    url_statuses.each do |url_status|
      url_status_lookup[url_status.id] = url_status.status
      url_status_name = (url_status.status + "_urls").to_sym
      @annotations[url_status_name] = {}
    end

    url_statistics.each do |url_statistic|
      url_status_type = (url_status_lookup[url_statistic.url_status_id] + "_urls").to_sym
      if @timeline_data.key?(url_statistic.created_at)
        @timeline_data[url_statistic.created_at][url_status_type] = url_statistic.count
      else
        @timeline_data[url_statistic.created_at] = {
          url_status_type => url_statistic.count
        }
      end
    end

    # XXX: The timeline graph doesn't properly display unless there's at least one value > 0 in each
    # dataset.  We perform a pseudo-sanity check here.
    if !url_statistics.first.nil?
      @timeline_data[url_statistics.first.created_at].each do |type,count|
        if count <= 0
          @timeline_data[url_statistics.first.created_at][type] = 1
        end
      end
    end

    # Collect all relevant suspicious and compromised URLs.
    conditions = conditions_for_url_collection
    conditions << "urls.time_at >= " + eval(timeline_display_age + ".ago").to_f.to_s
    @suspicious_urls = Url.find(:all, :conditions => (conditions + ['urls.url_status_id = ' + UrlStatus.find_by_status('suspicious').id.to_s]).join(' AND '), :order => 'urls.time_at DESC')
    @compromised_urls = Url.find(:all, :conditions => (conditions + ['urls.url_status_id = ' + UrlStatus.find_by_status('compromised').id.to_s]).join(' AND '), :order => 'urls.time_at DESC')

    # Gauge Constants
    @gauge_size = Configuration.find_retry(:name => "ui.gauge.size", :namespace => "UrlStatistic")

    # URL Queue Gauge
    @url_queue_size = Url.calculate_without_cache(:count, :id, :conditions => {:url_status_id => UrlStatus.find_by_status("queued").id})
    # XXX: Disable caching.
    #@url_queue_size = Url.count(:conditions => {:url_status_id => UrlStatus.find_by_status("queued").id})
    @url_queue_gauge_min = Configuration.find_retry(:name => "ui.url_queue_gauge.min", :namespace => "UrlStatistic")
    @url_queue_gauge_max = Configuration.find_retry(:name => "ui.url_queue_gauge.max", :namespace => "UrlStatistic")
    @url_queue_gauge_green_to = Configuration.find_retry(:name => "ui.url_queue_gauge.green_to", :namespace => "UrlStatistic")
    @url_queue_gauge_yellow_to = Configuration.find_retry(:name => "ui.url_queue_gauge.yellow_to", :namespace => "UrlStatistic")
    @url_queue_update_frequency = Configuration.find_retry(:name => "ui.url_queue.update_frequency", :namespace => "UrlStatistic")

    # Running VMs Gauge
    @running_vms_count = Client.calculate_without_cache(:count, :id, :conditions => {:client_status_id => ClientStatus.find_by_status("running").id}) 
    # XXX: Disable caching.
    #@running_vms_count = Client.count(:conditions => {:client_status_id => ClientStatus.find_by_status("running").id}) 
    @running_vms_gauge_min = Configuration.find_retry(:name => "ui.running_vms_gauge.min", :namespace => "UrlStatistic")
    @running_vms_gauge_max = Configuration.find_retry(:name => "ui.running_vms_gauge.max", :namespace => "UrlStatistic")
    @running_vms_gauge_red_to = Configuration.find_retry(:name => "ui.running_vms_gauge.red_to", :namespace => "UrlStatistic")
    @running_vms_gauge_yellow_to = Configuration.find_retry(:name => "ui.running_vms_gauge.yellow_to", :namespace => "UrlStatistic")
    @running_vms_update_frequency = Configuration.find_retry(:name => "ui.running_vms.update_frequency", :namespace => "UrlStatistic")

    latest_url = Url.find(:first, :order => 'urls.updated_at DESC')
    latest_client = Client.find(:first, :order => 'clients.updated_at DESC')
    latest_entry = latest_url
    if (latest_entry.nil? ||
        (!latest_client.nil? &&
        (latest_client.updated_at > latest_entry.updated_at)))
      latest_entry = latest_client
    end

    if stale?(:last_modified => (latest_entry.nil? ? Time.now.utc : Time.at(latest_entry.time_at.to_f).utc), :etag => latest_entry)
      respond_to do |format|
        format.html
        format.atom
      end
    end
  end

  def url_queue_size
    @url_queue_size = Url.calculate_without_cache(:count, :id, :conditions => {:url_status_id => UrlStatus.find_by_status("queued").id})
    # XXX: Disable caching.
    #@url_queue_size = Url.count(:conditions => {:url_status_id => UrlStatus.find_by_status("queued").id})
    render :json => {:url_queue_size => @url_queue_size}
  end

  def running_vms_count
    @running_vms_count = Client.calculate_without_cache(:count, :id, :conditions => {:client_status_id => ClientStatus.find_by_status("running").id}) 
    # XXX: Disable caching.
    #@running_vms_count = Client.count(:conditions => {:client_status_id => ClientStatus.find_by_status("running").id}) 
    render :json => {:running_vms_count => @running_vms_count}
  end

  # Restrict who can see what URL records in timeline UI.
  # Note: This should remain synchronized with UrlsController.conditions_for_collection.
  # - Admins can see everything.
  # - Users in groups can see only those corresponding records along with records not in any group.
  # - Users not in a group can see only those corresponding records.
  def conditions_for_url_collection
    return [ 'urls.group_id IS NULL' ] if current_user.nil?
    return [] if current_user.has_role?(:admin)
    groups = current_user.groups
    if (groups.size > 0)
      return [ '(urls.group_id IN (' + groups.map!{|g| g.is_a?(Group) ? g.id : g}.join(',') +  ') OR urls.group_id IS NULL)' ]
    else
      return [ 'urls.group_id IS NULL' ]
    end
  end
end
