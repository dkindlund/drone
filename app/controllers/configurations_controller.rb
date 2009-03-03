class ConfigurationsController < ApplicationController
  active_scaffold :configuration do |config|

    # Show the following columns in the specified order.
    config.list.columns = [:namespace, :name, :value, :description, :default_value]

    # Rename the following columns.
    config.columns[:default_value].label = "Default Value"
  end
end
