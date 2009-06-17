class ApplicationsController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column, :show_export, :export if (Rails.env.production? || Rails.env.development?)
  before_filter :login_required

  active_scaffold :application do |config|
    # Table Title
    config.list.label = "Driven Applications"

    # Show the following columns in the specified order.
    config.list.columns = [:manufacturer, :short_name, :version]
    config.show.columns = [:manufacturer, :short_name, :version]

    # Sort columns in the following order.
    config.list.sorting = {:version => :desc}

    # Rename the following columns.
    config.columns[:short_name].label = "Name"

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "Application Details"

    # Add export options.
    config.actions.add :export
    config.export.columns = [:manufacturer, :short_name, :version]
    config.export.force_quotes = true
    config.export.allow_full_download = true

    # Support ATOM Format
    config.formats << :atom
  end

  protected
  def list_respond_to_atom
    @applications = Application.find(:all, :order => 'applications.id DESC', :limit => Configuration.find_retry(:name => "atom.max_entries", :namespace => "Application").to_i)

    respond_to do |format|
        format.atom
    end
  end
end
