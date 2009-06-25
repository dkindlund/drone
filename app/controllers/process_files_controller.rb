class ProcessFilesController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column, :show_export, :export if (Rails.env.production? || Rails.env.development?)
  before_filter :login_required

  active_scaffold :process_file do |config|
    # Table Title
    config.list.label = "Filesystem Activity"

    # Show the following columns in the specified order.
    config.list.columns = [:time_at, :os_process, :event, :name, :file_content]
    config.show.columns = [:time_at, :os_process, :event, :name, :file_content]

    # Sort columns in the following order.
    config.list.sorting = {:time_at => :desc}

    # Rename the following columns.
    config.columns[:os_process].label = "Process Name"
    config.columns[:time_at].label = "When"
    config.columns[:name].label = "File Name"
    config.columns[:file_content].label = "File Content"

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "Filesystem Activity Details"

    # Include the following show actions.
    config.columns[:os_process].set_link :show, :controller => 'os_processes', :parameters => {:parent_controller => 'process_files'}
    config.columns[:file_content].set_link :show, :controller => 'file_contents', :parameters => {:parent_controller => 'process_files'}

    # Add export options.
    config.actions.add :export
    config.export.columns = [:time_at, :os_process, :event, :name, :file_content]
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
    process_files = ProcessFile.find(:all, :select => 'DISTINCT process_files.*, urls.id AS url_id', :from => 'process_files', :joins => 'LEFT JOIN file_contents ON file_contents.id = process_files.file_content_id LEFT JOIN os_processes ON os_processes.id = process_files.os_process_id LEFT JOIN urls ON urls.fingerprint_id = os_processes.fingerprint_id', :conditions => ProcessFile.merge_conditions(url_conditions, ['file_contents.size > 0 AND file_contents.mime_type != \'UNKNOWN\' AND urls.url_status_id IN (?,?)', UrlStatus.find_by_status("suspicious").id, UrlStatus.find_by_status("compromised").id]), :order => 'process_files.time_at DESC', :limit => Configuration.find_retry(:name => "atom.max_entries", :namespace => "ProcessFile").to_i)
    urls = Url.find(:all, :select => 'DISTINCT urls.*, process_files.id AS process_file_id', :from => 'process_files', :joins => 'LEFT JOIN file_contents ON file_contents.id = process_files.file_content_id LEFT JOIN os_processes ON os_processes.id = process_files.os_process_id LEFT JOIN urls ON urls.fingerprint_id = os_processes.fingerprint_id', :conditions => Url.merge_conditions(url_conditions, ['file_contents.size > 0 AND file_contents.mime_type != \'UNKNOWN\' AND urls.url_status_id IN (?,?)', UrlStatus.find_by_status("suspicious").id, UrlStatus.find_by_status("compromised").id]), :order => 'process_files.time_at DESC', :limit => Configuration.find_retry(:name => "atom.max_entries", :namespace => "ProcessFile").to_i)
    @data = process_files.zip(urls)

    respond_to do |format|
        format.atom
    end
  end
end
