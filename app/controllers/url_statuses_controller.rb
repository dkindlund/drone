class UrlStatusesController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column
  before_filter :login_required

  active_scaffold :url_status do |config|
    # Table Title
    config.list.label = "URL Status Types"

    # Show the following columns in the specified order.
    config.list.columns = [:status, :description]

    # Sort columns in the following order.
    config.list.sorting = {:status => :asc}

    # Disable eager loading for the following attributes.
    config.columns[:urls].includes = nil

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "URL Status Details"
  end
end
