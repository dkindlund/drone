class HostsController < ApplicationController
  active_scaffold :host do |config|
    # Show the following columns in the specified order.
    config.list.columns = [:hostname, :ip, :created_at, :updated_at]

    # Disable eager loading for the following attributes.
    config.columns[:clients].includes = nil

    # Rename the following columns.
    config.columns[:ip].label = "IP Address"
    config.columns[:created_at].label = "Created"
    config.columns[:updated_at].label = "Updated"
  end
end
