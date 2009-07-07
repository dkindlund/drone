class OsProcessesController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column, :show_export, :export if (Rails.env.production? || Rails.env.development?)
  before_filter :login_required
  before_filter :check_for_nested_fingerprints

  active_scaffold :os_process do |config|
    # Table Title
    config.list.label = "Process Activity"

    # Show the following columns in the specified order.
    config.list.columns = [:fingerprint, :name, :pid, :parent_name, :parent_pid, :process_file_count, :process_registry_count]
    config.show.columns = [:fingerprint, :name, :pid, :parent_name, :parent_pid]

    # Sort columns in the following order.
    config.list.sorting = {:name => :asc}

    # Rename the following columns.
    config.columns[:pid].label = "PID"
    config.columns[:parent_name].label = "Parent Name"
    config.columns[:parent_pid].label = "Parent PID"
    config.columns[:process_file_count].label = "# Files"
    config.columns[:process_registry_count].label = "# Registries"

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "Process Details"

    # Disable eager loading of the following associations.
    config.list.columns.exclude :process_files, :process_registries
    config.show.columns.exclude :process_files, :process_registries

    # Include the following show actions.
    config.columns[:fingerprint].set_link :show, :controller => 'fingerprints', :parameters => {:parent_controller => 'os_processes'}

    # Add export options.
    config.actions.add :export
    config.export.columns = [:fingerprint, :name, :pid, :parent_name, :parent_pid, :process_file_count, :process_registry_count]
    config.export.force_quotes = true
    config.export.allow_full_download = true

    # Support ATOM Format
    config.formats << :atom
  end

  # Helper function to determine if the os_processes view should show
  # nested fingerprints.
  def check_for_nested_fingerprints
    if (params[:parent_controller] == "process_files" || params[:parent_controller] == "process_registries")
      @show_nested_fingerprints = true
    else
      @show_nested_fingerprints = false
    end
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
    os_processes = OsProcess.find(:all, :select => 'DISTINCT os_processes.*, urls.id AS url_id', :from => 'os_processes', :joins => 'LEFT JOIN urls ON urls.fingerprint_id = os_processes.fingerprint_id', :conditions => OsProcess.merge_conditions(url_conditions, ['urls.url_status_id IN (?,?)', UrlStatus.find_by_status("suspicious").id, UrlStatus.find_by_status("compromised").id]), :order => 'os_processes.id DESC', :limit => Configuration.find_retry(:name => "atom.max_entries", :namespace => "OsProcess").to_i)
    urls = Url.find(:all, :select => 'DISTINCT urls.*, os_processes.id AS os_process_id', :from => 'os_processes', :joins => 'LEFT JOIN urls ON urls.fingerprint_id = os_processes.fingerprint_id', :conditions => Url.merge_conditions(url_conditions, ['urls.url_status_id IN (?,?)', UrlStatus.find_by_status("suspicious").id, UrlStatus.find_by_status("compromised").id]), :order => 'os_processes.id DESC', :limit => Configuration.find_retry(:name => "atom.max_entries", :namespace => "OsProcess").to_i)
    @data = os_processes.zip(urls)

    if stale?(:last_modified => (@data.first.nil? ? Time.now.utc : Time.at(@data.first[1].time_at.to_f).utc), :etag => @data.first[1])
      respond_to do |format|
        format.atom
      end
    end
  end
end
