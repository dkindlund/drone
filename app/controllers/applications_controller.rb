class ApplicationsController < ApplicationController
  active_scaffold :application do |config|
    # Show the following columns in the specified order.
    config.list.columns = [:manufacturer, :short_name, :version]

    # Rename the following columns.
    config.columns[:short_name].label = "Name"
  end
end
