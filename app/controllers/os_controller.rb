class OsController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column, :show_export, :export if (Rails.env.production? || Rails.env.development?)
  before_filter :login_required

  active_scaffold :os do |config|
    # Table Title
    config.list.label = "Operating System Types"

    # Show the following columns in the specified order.
    config.list.columns = [:short_name, :name, :version]
    config.show.columns = [:short_name, :name, :version]

    # Sort columns in the following order.
    config.list.sorting = {:version => :desc}

    # Disable eager loading for the following attributes.
    config.columns[:clients].includes = nil

    # Rename the following columns.
    config.columns[:short_name].label = "Short Name"

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "OS Details"

    # Add export options.
    config.actions.add :export
    config.export.columns = [:short_name, :name, :version]
    config.export.force_quotes = true
    config.export.allow_full_download = true

    # Support ATOM Format
    config.formats << :atom
  end

  protected
  def list_respond_to_atom
    @oses = Os.find(:all, :order => 'os.id DESC', :limit => Configuration.find_retry(:name => "atom.max_entries", :namespace => "Os").to_i)

    respond_to do |format|
      format.atom
    end
  end
end
