class ProcessRegistriesController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column, :show_export, :export if (Rails.env.production? || Rails.env.development?)
  before_filter :login_required

  active_scaffold :process_registry do |config|
    # Table Title
    config.list.label = "Registry Activity"

    # Show the following columns in the specified order.
    config.list.columns = [:time_at, :os_process, :event, :name, :value_name, :value_type, :value]
    config.show.columns = [:time_at, :os_process, :event, :name, :value_name, :value_type, :value]

    # Sort columns in the following order.
    config.list.sorting = {:time_at => :desc}

    # Rename the following columns.
    config.columns[:os_process].label = "Process Name"
    config.columns[:time_at].label = "When"
    config.columns[:name].label = "Registry Name"
    config.columns[:value_name].label = "Value Name"
    config.columns[:value_type].label = "Value Type"

    # Make sure the value column is searchable.
    config.columns[:value].search_sql = 'process_registries.value'
    config.search.columns << :value

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "Registry Activity Details"

    # Include the following show actions.
    config.columns[:os_process].set_link :show, :controller => 'os_processes', :parameters => {:parent_controller => 'process_registries'}

    # Add export options.
    config.actions.add :export
    config.export.columns = [:time_at, :os_process, :event, :name, :value_name, :value_type, :value]
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
    process_registries = ProcessRegistry.find(:all, :select => 'DISTINCT process_registries.*, urls.id AS url_id', :from => 'process_registries', :joins => 'LEFT JOIN os_processes ON os_processes.id = process_registries.os_process_id LEFT JOIN urls ON urls.fingerprint_id = os_processes.fingerprint_id', :conditions => ProcessRegistry.merge_conditions(url_conditions, ['urls.url_status_id IN (?,?)', UrlStatus.find_by_status("suspicious").id, UrlStatus.find_by_status("compromised").id]), :order => 'process_registries.time_at DESC', :limit => Configuration.find_retry(:name => "atom.max_entries", :namespace => "ProcessRegistry").to_i)
    urls = Url.find(:all, :select => 'DISTINCT urls.*, process_registries.id AS process_registry_id', :from => 'process_registries', :joins => 'LEFT JOIN os_processes ON os_processes.id = process_registries.os_process_id LEFT JOIN urls ON urls.fingerprint_id = os_processes.fingerprint_id', :conditions => Url.merge_conditions(url_conditions, ['urls.url_status_id IN (?,?)', UrlStatus.find_by_status("suspicious").id, UrlStatus.find_by_status("compromised").id]), :order => 'process_registries.time_at DESC', :limit => Configuration.find_retry(:name => "atom.max_entries", :namespace => "ProcessRegistry").to_i)
    @data = process_registries.zip(urls)

    if stale?(:last_modified => (@data.first.nil? ? Time.now.utc : Time.at(@data.first[1].time_at.to_f).utc), :etag => @data.first[1])
      respond_to do |format|
        format.atom
      end
    end
  end
end
