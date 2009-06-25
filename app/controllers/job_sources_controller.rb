class JobSourcesController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column, :show_export, :export if (Rails.env.production? || Rails.env.development?)
  before_filter :login_required
  before_filter :admin_required, :only => [:index, :list]

  active_scaffold :job_source do |config|
    # Table Title
    config.list.label = "Job Sources"

    # Show the following columns in the specified order.
    config.list.columns = [:name, :protocol]
    config.show.columns = [:name, :protocol]

    # Sort columns in the following order.
    config.list.sorting = {:name => :asc}

    # Disable eager loading for the following attributes.
    config.columns[:jobs].includes = nil

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "Source Details"

    # Use field searching.
    config.actions.swap :search, :field_search

    # Add export options.
    config.actions.add :export
    config.export.columns = [:name, :protocol]
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
    return [ 'job_sources.group_id IS NULL' ] if current_user.nil?
    return [] if current_user.has_role?(:admin)
    groups = current_user.groups
    if (groups.size > 0)
      return [ '(job_sources.group_id IN (?) OR job_sources.group_id IS NULL)', groups.map!{|g| g.is_a?(Group) ? g.id : g} ]
    else
      return [ 'job_sources.group_id IS NULL' ]
    end
  end

  protected
  def list_respond_to_atom
    @job_sources = JobSource.find(:all, :conditions => conditions_for_collection, :order => 'job_sources.id DESC', :limit => Configuration.find_retry(:name => "atom.max_entries", :namespace => "JobSource").to_i)

    respond_to do |format|
        format.atom
    end
  end

  def admin_required
    if (current_user.nil? || !current_user.has_role?(:admin))
      redirect_back_or_default('/')
    end
  end
end
