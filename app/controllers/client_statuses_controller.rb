class ClientStatusesController < ApplicationController
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
  end
end
