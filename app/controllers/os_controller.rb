class OsController < ApplicationController
  active_scaffold :os do |config|
    # Show the following columns in the specified order.
    config.list.columns = [:short_name, :name, :version]

    # Disable eager loading for the following attributes.
    config.columns[:clients].includes = nil

    # Rename the following columns.
    config.columns[:short_name].label = "Short Name"
  end
end
