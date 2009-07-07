class FingerprintsController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column, :show_export, :export if (Rails.env.production? || Rails.env.development?)
  before_filter :login_required
  before_filter :check_for_nested_urls

  active_scaffold :fingerprint do |config|
    # Table Title
    config.list.label = "Fingerprints"

    # Show the following columns in the specified order.
    config.list.columns = [:checksum, :os_process_count]

    # Sort columns in the following order.
    config.list.sorting = {:checksum => :asc}

    # Rename the following columns.
    config.columns[:os_process_count].label = "# Processes Found"
    config.columns[:pcap].label = "Packet Capture"

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "Fingerprint Details"

    # Add export options.
    config.actions.add :export
    config.export.columns = [:checksum, :os_process_count]
    config.export.force_quotes = true
    config.export.allow_full_download = true

    # Support ATOM Format
    config.formats << :atom
  end

  # Helper function to determine if the fingerprint view should show
  # nested URLs.
  def check_for_nested_urls
    if params[:parent_controller] == "urls"
      @show_nested_urls = false
    else
      @show_nested_urls = true
    end
  end

  # Helper function to allow users to download any corresponding PCAP.
  def download_pcap
    fingerprint = nil
    begin    
      fingerprint = Fingerprint.find(params[:id])
    rescue
      fingerprint = nil
    end
    if (!fingerprint.nil? &&
        !fingerprint.pcap.nil? &&
        (fingerprint.url.group_id.nil? ||
         current_user.has_role?(:admin) ||
         !current_user.groups.map{|g| g.is_a?(Group) ? g.id : g}.index(fingerprint.url.group_id).nil?))
      send_file(RAILS_ROOT + '/' + fingerprint.pcap.to_s, :x_sendfile => true)
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
    fingerprints = Fingerprint.find(:all, :select => 'DISTINCT fingerprints.*, urls.id AS url_id', :from => 'fingerprints', :joins => 'LEFT JOIN urls ON urls.fingerprint_id = fingerprints.id', :conditions => Fingerprint.merge_conditions(url_conditions, ['urls.url_status_id IN (?,?)', UrlStatus.find_by_status("suspicious").id, UrlStatus.find_by_status("compromised").id]), :order => 'fingerprints.id DESC', :limit => Configuration.find_retry(:name => "atom.max_entries", :namespace => "Fingerprint").to_i)
    urls = Url.find(:all, :select => 'DISTINCT urls.*, fingerprints.id AS fingerprint_id', :from => 'fingerprints', :joins => 'LEFT JOIN urls ON urls.fingerprint_id = fingerprints.id', :conditions => Url.merge_conditions(url_conditions, ['urls.url_status_id IN (?,?)', UrlStatus.find_by_status("suspicious").id, UrlStatus.find_by_status("compromised").id]), :order => 'fingerprints.id DESC', :limit => Configuration.find_retry(:name => "atom.max_entries", :namespace => "Fingerprint").to_i)
    @data = fingerprints.zip(urls)

    if stale?(:last_modified => (@data.first.nil? ? Time.now.utc : Time.at(@data.first[1].time_at.to_f).utc), :etag => @data.first[1])
      respond_to do |format|
        format.atom
      end
    end
  end
end
