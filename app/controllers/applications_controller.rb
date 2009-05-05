class ApplicationsController < ApplicationController
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
  end
end
