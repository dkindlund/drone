class ConfigurationsController < ApplicationController
  active_scaffold :configuration do |config|
    # Table Title
    config.list.label = "Configurations"

    # Show the following columns in the specified order.
    config.list.columns = [:namespace, :name, :value, :description, :default_value]

    # Sort columns in the following order.
    config.list.sorting = [{:namespace => :asc}, {:name => :asc}, {:value => :asc}]

    # Rename the following columns.
    config.columns[:default_value].label = "Default Value"
  end
end
