class OsProcessesController < ApplicationController
  active_scaffold :os_process do |config|
    # Show the following columns in the specified order.
    config.list.columns = [:fingerprint, :name, :pid, :parent_name, :parent_pid, :process_file_count, :process_registry_count]

    # Rename the following columns.
    config.columns[:pid].label = "PID"
    config.columns[:parent_name].label = "Parent Name"
    config.columns[:parent_pid].label = "Parent PID"
    config.columns[:process_file_count].label = "# Files"
    config.columns[:process_registry_count].label = "# Registries"
  end
end
