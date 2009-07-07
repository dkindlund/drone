class UrlsController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column, :show_export, :export if (Rails.env.production? || Rails.env.development?)
  before_filter :login_required

  active_scaffold :url do |config|
    # Table Title
    config.list.label = "URLs"

    # Add virtual field: job_source
    config.columns << :job_source

    # Show the following columns in the specified order.
    config.list.columns = [:job, :job_source, :url, :ip, :priority, :url_status, :time_at, :client, :fingerprint, :updated_at]
    config.show.columns = [:job, :job_source, :url, :ip, :priority, :url_status, :time_at, :client, :fingerprint, :created_at, :updated_at]

    # Sort columns in the following order.
    config.list.sorting = {:time_at => :desc}

    # Rename the following columns.
    config.columns[:job].label = "Job ID"
    config.columns[:job_source].label = "Job Source"
    config.columns[:url].label = "URL"
    config.columns[:ip].label = "IP"
    config.columns[:url_status].label = "Status"
    config.columns[:time_at].label = "Visited"
    config.columns[:created_at].label = "Created"
    config.columns[:updated_at].label = "Updated"

    # Make sure the url_status column is searchable.
    config.columns[:url_status].search_sql = 'url_statuses.status'
    config.search.columns << :url_status

    # Make sure the fingerprint column is searchable.
    config.columns[:fingerprint].search_sql = 'fingerprints.checksum'
    config.search.columns << :fingerprint

    # Make sure the job column is searchable.
    config.columns[:job].search_sql = 'jobs.uuid'
    config.search.columns << :job

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "URL Details"

    # Include the following show actions.
    config.columns[:fingerprint].set_link :show, :controller => 'fingerprints', :parameters => {:parent_controller => 'urls'}
    config.columns[:client].set_link :show, :controller => 'clients', :parameters => {:parent_controller => 'urls'}
    config.columns[:job].set_link :show, :controller => 'jobs', :parameters => {:parent_controller => 'urls'}
    # TODO: Should provide this next one as a tooltip.
    # TODO: ? config.columns[:url_status].set_link :show, :controller => 'url_statuses', :parameters => {:parent_controller => 'urls'}

    # Disable eager loading of the following associations.
    # TODO: Check if this is needed for performance reasons; if we enable it, be sure to remove the job column searchability.
    #config.columns[:job].includes = nil
    config.columns[:client].includes = nil
    # TODO: Check if this is needed for performance reasons; if we enable it, be sure to remove the fingerprint column searchability.
    #config.columns[:fingerprint].includes = nil

    # Add export options.
    config.actions.add :export
    config.export.columns = [:job, :job_source, :url, :ip, :priority, :url_status, :time_at, :client, :fingerprint, :created_at, :updated_at]
    config.export.force_quotes = true
    config.export.allow_full_download = true

    # Support ATOM Format
    config.formats << :atom
  end

  # Restrict who can see what records in list view.
  # - Admins can see everything.
  # - Users in groups can see only those corresponding records along with records not in any group.
  # - Users not in a group can see only those corresponding records.
  def conditions_for_collection
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
    url_conditions = conditions_for_collection
    urls = Url.find(:all, :select => 'DISTINCT urls.*, fingerprints.id AS fingerprint_id', :from => 'urls', :joins => 'LEFT JOIN fingerprints ON fingerprints.id = urls.fingerprint_id', :conditions => Url.merge_conditions(url_conditions, ['urls.url_status_id IN (?,?)', UrlStatus.find_by_status("suspicious").id, UrlStatus.find_by_status("compromised").id]), :order => 'urls.time_at DESC', :limit => Configuration.find_retry(:name => "atom.max_entries", :namespace => "Url").to_i)
    fingerprints = Fingerprint.find(:all, :select => 'DISTINCT fingerprints.*, urls.id AS url_id', :from => 'urls', :joins => 'LEFT JOIN fingerprints ON fingerprints.id = urls.fingerprint_id', :conditions => Fingerprint.merge_conditions(url_conditions, ['urls.url_status_id IN (?,?)', UrlStatus.find_by_status("suspicious").id, UrlStatus.find_by_status("compromised").id]), :order => 'urls.time_at DESC', :limit => Configuration.find_retry(:name => "atom.max_entries", :namespace => "Url").to_i)
    @data = urls.zip(fingerprints)

    if stale?(:last_modified => (@data.first.nil? ? Time.now.utc : Time.at(@data.first[0].time_at.to_f).utc), :etag => @data.first[0])
      respond_to do |format|
        format.atom
      end
    end
  end
end
