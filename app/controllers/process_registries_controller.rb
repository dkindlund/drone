class ProcessRegistriesController < ApplicationController
  active_scaffold :process_registry do |config|
    # Table Title
    config.list.label = "Registry Activity"

    # Show the following columns in the specified order.
    config.list.columns = [:time_at, :os_process, :event, :name, :value_name, :value_type, :value]

    # Sort columns in the following order.
    config.list.sorting = {:time_at => :desc}

    # Rename the following columns.
    config.columns[:os_process].label = "Process Name"
    config.columns[:time_at].label = "When"
    config.columns[:name].label = "Registry Name"
    config.columns[:value_name].label = "Value Name"
    config.columns[:value_type].label = "Value Type"
  end
end
