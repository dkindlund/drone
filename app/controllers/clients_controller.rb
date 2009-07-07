class ClientsController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column, :show_export, :export if (Rails.env.production? || Rails.env.development?)
  before_filter :login_required

  active_scaffold :client do |config|
    # Table Title
    config.list.label = "Client List"

    # Show the following columns in the specified order.
    config.list.columns = [:id, :quick_clone_name, :snapshot_name, :client_status, :job_count, :created_at, :suspended_at, :host, :os, :application]
    config.show.columns = [:id, :quick_clone_name, :snapshot_name, :client_status, :job_count, :created_at, :suspended_at, :updated_at, :host, :os, :application, :ip, :mac]
    config.update.columns = [:client_status]

    # Sort columns in the following order.
    config.list.sorting = [{:suspended_at => :desc}, {:updated_at => :desc}]

    # Rename the following columns.
    config.columns[:id].label = "ID"
    config.columns[:quick_clone_name].label = "VM Name"
    config.columns[:snapshot_name].label = "Snapshot Name"
    config.columns[:client_status].label = "Status"
    config.columns[:job_count].label = "# Jobs"
    config.columns[:created_at].label = "Created"
    config.columns[:suspended_at].label = "Suspended"
    config.columns[:updated_at].label = "Updated"
    config.columns[:os].label = "OS"
    config.columns[:ip].label = "IP Address"
    config.columns[:mac].label = "MAC Address"

    # Make sure the client_status column is searchable.
    config.columns[:client_status].search_sql = 'client_statuses.status'
    config.search.columns << :client_status
    
    # Make sure the id column is searchable.
    config.columns[:id].search_sql = 'clients.id'
    config.search.columns << :id

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "Client Details"

    # Include the following show actions.
    config.columns[:host].set_link :show, :controller => 'hosts', :parameters => {:parent_controller => 'clients'}
    config.columns[:os].set_link :show, :controller => 'os', :parameters => {:parent_controller => 'clients'}
    config.columns[:application].set_link :show, :controller => 'applications', :parameters => {:parent_controller => 'clients'}
    # TODO: Should provide this next one as a tooltip.
    # TODO: ? config.columns[:client_status].set_link :show, :controller => 'client_statuses', :parameters => {:parent_controller => 'clients'}

    # Add export options.
    config.actions.add :export
    config.export.columns = [:id, :quick_clone_name, :snapshot_name, :client_status, :job_count, :created_at, :suspended_at, :updated_at, :host, :os, :application, :ip, :mac]
    config.export.force_quotes = true
    config.export.allow_full_download = true

    # Support ATOM Format
    config.formats << :atom
  end

  # XXX: This should mimic UrlsController.conditions_for_collection.
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
    clients = Client.find(:all, :select => 'DISTINCT clients.*, urls.id AS url_id', :from => 'clients', :joins => 'LEFT JOIN urls ON urls.client_id = clients.id', :conditions => Client.merge_conditions(url_conditions, ['urls.url_status_id IN (?,?)', UrlStatus.find_by_status("suspicious").id, UrlStatus.find_by_status("compromised").id]), :order => 'urls.time_at DESC', :limit => Configuration.find_retry(:name => "atom.max_entries", :namespace => "Client").to_i)
    urls = Url.find(:all, :select => 'DISTINCT urls.*', :from => 'urls', :conditions => Url.merge_conditions(url_conditions, ['urls.url_status_id IN (?,?)', UrlStatus.find_by_status("suspicious").id, UrlStatus.find_by_status("compromised").id]), :order => 'urls.time_at DESC', :limit => Configuration.find_retry(:name => "atom.max_entries", :namespace => "Client").to_i)
    @data = clients.zip(urls)

    if stale?(:last_modified => (@data.first.nil? ? Time.now.utc : Time.at(@data.first[1].time_at.to_f).utc), :etag => @data.first[1])
      respond_to do |format|
        format.atom
      end
    end
  end

  # Calculate the new last URL status, based upon the client status.
  def after_update_save(record)
    last_url_status = nil
    client_status = record.client_status.status.to_s
    if client_status == "suspicious"
      last_url_status = UrlStatus.find_by_status("suspicious")
    elsif client_status == "compromised"
      last_url_status = UrlStatus.find_by_status("compromised")
    elsif client_status == "deleted"
      last_url_status = UrlStatus.find_by_status("ignored")
    elsif client_status == "false_positive"
      last_url_status = UrlStatus.find_by_status("visited")
    elsif client_status == "error"
      last_url_status = UrlStatus.find_by_status("error")
    end

    if !last_url_status.nil?
      # When we update the client status field, make sure last URL entry is also updated (if needed).
      last_url = Url.find(:first, :conditions => ["urls.client_id = ?", record.id], :order => "urls.time_at DESC")
      if !last_url.nil?
        last_url.url_status = last_url_status
        last_url.save!
        last_url.expire_caches
      end
    end
    return record
  end
end
