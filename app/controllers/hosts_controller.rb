class HostsController < ApplicationController
  active_scaffold :host do |config|
    # Table Title
    config.list.label = "VMware ESX Hosts"

    # Show the following columns in the specified order.
    config.list.columns = [:hostname, :ip, :created_at, :updated_at]

    # Sort columns in the following order.
    config.list.sorting = {:hostname => :asc}

    # Disable eager loading for the following attributes.
    config.columns[:clients].includes = nil

    # Rename the following columns.
    config.columns[:ip].label = "IP Address"
    config.columns[:created_at].label = "Created"
    config.columns[:updated_at].label = "Updated"
  end
end
