class OsProcessesController < ApplicationController
  active_scaffold :os_process do |config|
    # Table Title
    config.list.label = "Process Activity"

    # Show the following columns in the specified order.
    config.list.columns = [:fingerprint, :name, :pid, :parent_name, :parent_pid, :process_file_count, :process_registry_count]

    # Sort columns in the following order.
    config.list.sorting = {:name => :asc}

    # Rename the following columns.
    config.columns[:pid].label = "PID"
    config.columns[:parent_name].label = "Parent Name"
    config.columns[:parent_pid].label = "Parent PID"
    config.columns[:process_file_count].label = "# Files"
    config.columns[:process_registry_count].label = "# Registries"
  end
end
