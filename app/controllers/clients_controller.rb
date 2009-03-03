class ClientsController < ApplicationController
  active_scaffold :client do |config|
    # Show the following columns in the specified order.
    config.list.columns = [:quick_clone_name, :snapshot_name, :client_status, :url_count, :created_at, :suspended_at, :host, :os, :application]

    # Disable eager loading for the following attributes.
    config.columns[:client_status].includes = nil
    config.columns[:host].includes = nil
    config.columns[:os].includes = nil
    config.columns[:application].includes = nil
    config.columns[:urls].includes = nil

    # Disable sub-form editing for the following attributes.
    #config.columns[:client_status].ui_type = :select
    #config.columns[:host].ui_type = :select
    #config.columns[:os].ui_type = :select
    #config.columns[:application].ui_type = :select
    #config.columns[:urls].ui_type = :select

    # Rename the following columns.
    config.columns[:quick_clone_name].label = "VM Name"
    config.columns[:snapshot_name].label = "Snapshot Name"
    config.columns[:client_status].label = "Status"
    config.columns[:url_count].label = "# URLs"
    config.columns[:created_at].label = "Created"
    config.columns[:suspended_at].label = "Suspended"
    config.columns[:os].label = "OS"
  end
end
