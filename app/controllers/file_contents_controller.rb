class FileContentsController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column, :show_export, :export, :download_data if (Rails.env.production? || Rails.env.development?)
  before_filter :login_required
  before_filter :check_for_nested_process_files

  active_scaffold :file_content do |config|
    # Table Title
    config.list.label = "File Contents"

    # Show the following columns in the specified order.
    config.list.columns = [:mime_type, :size, :md5, :sha1]
    config.show.columns = [:mime_type, :size, :md5, :sha1, :data]

    # Sort columns in the following order.
    config.list.sorting = {:sha1 => :asc}

    # Disable eager loading for the following attributes.
    config.columns[:process_files].includes = nil

    # Rename the following columns.
    config.columns[:md5].label = "MD5"
    config.columns[:sha1].label = "SHA1"
    config.columns[:mime_type].label = "Type"
    config.columns[:size].label = "Size (Bytes)"
    config.columns[:process_files].label = "Process Files"

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "File Details"

    # Add export options.
    config.actions.add :export
    config.export.columns = [:mime_type, :size, :md5, :sha1]
    config.export.force_quotes = true
    config.export.allow_full_download = true

    # Support ATOM Format
    config.formats << :atom
  end

  # Helper function to determine if the file_contents view should show
  # nested process_files.
  def check_for_nested_process_files
    if params[:parent_controller] == "process_files"
      @show_nested_process_files = false
    else
      @show_nested_process_files = true
    end
  end

  # Helper function to allow users to download data for any corresponding FileContent.
  def download_data
    file_content = nil
    begin
      file_content = FileContent.find(params[:id])
    rescue
      file_content = nil
    end

    # We need to figure out which groups are allowed to download this file content.
    # Unfortunately, this requires iterating through any referenced URLs and collecting
    # all applicable group_ids.
    group_ids = []
    if (!file_content.nil? &&
        !file_content.data.nil?)
      file_content.process_files.each do |process_file|
        if (!process_file.os_process.nil? &&
            !process_file.os_process.fingerprint.nil? &&
            !process_file.os_process.fingerprint.url.nil?)
          # Clear the cache, if need be.
          process_file.os_process.fingerprint.url.expire_caches
          group_ids << process_file.os_process.fingerprint.url.group_id
        end
      end
      group_ids.uniq!
    end

    if (!file_content.nil? &&
        !file_content.data.nil? &&
        (!group_ids.index(nil).nil? ||
         current_user.has_role?(:admin) ||
         ((current_user.groups.map{|g| g.is_a?(Group) ? g.id : g} & group_ids).size > 0)))
      send_file(RAILS_ROOT + '/' + file_content.data.to_s, :x_sendfile => true)
    else
      redirect_back_or_default('/')
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
    file_contents = FileContent.find(:all, :select => 'DISTINCT file_contents.*, urls.id AS url_id', :from => 'file_contents', :joins => 'LEFT JOIN process_files ON process_files.file_content_id = file_contents.id LEFT JOIN os_processes ON os_processes.id = process_files.os_process_id LEFT JOIN urls ON urls.fingerprint_id = os_processes.fingerprint_id', :conditions => FileContent.merge_conditions(url_conditions, ['file_contents.size > 0 AND file_contents.mime_type != \'UNKNOWN\' AND urls.url_status_id IN (?,?)', UrlStatus.find_by_status("suspicious").id, UrlStatus.find_by_status("compromised").id]), :order => 'file_contents.id DESC', :limit => Configuration.find_retry(:name => "atom.max_entries", :namespace => "FileContent").to_i)
    urls = Url.find(:all, :select => 'DISTINCT urls.*, file_contents.id AS file_content_id', :from => 'file_contents', :joins => 'LEFT JOIN process_files ON process_files.file_content_id = file_contents.id LEFT JOIN os_processes ON os_processes.id = process_files.os_process_id LEFT JOIN urls ON urls.fingerprint_id = os_processes.fingerprint_id', :conditions => Url.merge_conditions(url_conditions, ['file_contents.size > 0 AND file_contents.mime_type != \'UNKNOWN\' AND urls.url_status_id IN (?,?)', UrlStatus.find_by_status("suspicious").id, UrlStatus.find_by_status("compromised").id]), :order => 'file_contents.id DESC', :limit => Configuration.find_retry(:name => "atom.max_entries", :namespace => "FileContent").to_i)
    @data = file_contents.zip(urls)

    if stale?(:last_modified => (@data.first.nil? ? Time.now.utc : Time.at(@data.first[1].time_at.to_f).utc), :etag => @data.first[1])
      respond_to do |format|
        format.atom
      end
    end
  end
end
