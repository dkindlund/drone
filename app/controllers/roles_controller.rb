class RolesController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column, :show_export, :export if (Rails.env.production? || Rails.env.development?)
  before_filter :login_required
  before_filter :admin_required

  active_scaffold :roles do |config|
    # Table Title
    config.list.label = "Roles"

    # Show the following columns in the specified order.
    config.list.columns = [:name, :description]

    # Sort columns in the following order.
    config.list.sorting = {:name => :asc}

    # Exclude the following actions.
    config.actions.exclude :show

    # Add export options.
    config.actions.add :export
    config.export.columns = [:name, :description]
    config.export.force_quotes = true
    config.export.allow_full_download = true

    # Support ATOM Format
    config.formats << :atom
  end

  protected
  def list_respond_to_atom
    @roles = Role.find(:all, :order => 'roles.id DESC', :limit => Configuration.find_retry(:name => "atom.max_entries", :namespace => "Role").to_i)

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
