class OsController < ApplicationController
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
  end
end
