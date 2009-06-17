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
  end

  protected

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
