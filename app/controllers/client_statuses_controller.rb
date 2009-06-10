class ClientStatusesController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column if (Rails.env.production? || Rails.env.development?)
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
  end
end
