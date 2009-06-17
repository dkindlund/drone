class ClientStatusesController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column, :show_export, :export if (Rails.env.production? || Rails.env.development?)
  before_filter :login_required

  active_scaffold :client_status do |config|
    # Table Title
    config.list.label = "Client Status Types"

    # Show the following columns in the specified order.
    config.list.columns = [:status, :description]

    # Sort columns in the following order.
    config.list.sorting = {:status => :asc}

    # Disable eager loading for the following attributes.
    config.columns[:clients].includes = nil

    # Exclude the following actions.
    config.actions.exclude :show

    # When showing this data on a subform, only show the status field.
    config.subform.columns = [:status]

    # Add export options.
    config.actions.add :export
    config.export.columns = [:status, :description]
    config.export.force_quotes = true
    config.export.allow_full_download = true

    # Support ATOM Format
    config.formats << :atom
  end

  protected
  def list_respond_to_atom
    @client_statuses = ClientStatus.find(:all, :order => 'client_statuses.id DESC', :limit => Configuration.find_retry(:name => "atom.max_entries", :namespace => "ClientStatus").to_i)

    respond_to do |format|
        format.atom
    end
  end
end
