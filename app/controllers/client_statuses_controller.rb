class ClientStatusesController < ApplicationController
  active_scaffold :client_status do |config|
    # Show the following columns in the specified order.
    config.list.columns = [:status, :description]

    # Disable eager loading for the following attributes.
    config.columns[:clients].includes = nil
  end
end
