class OsProcessesController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column
  before_filter :login_required
  before_filter :check_for_nested_fingerprints

  active_scaffold :os_process do |config|
    # Table Title
    config.list.label = "Process Activity"

    # Show the following columns in the specified order.
    config.list.columns = [:fingerprint, :name, :pid, :parent_name, :parent_pid, :process_file_count, :process_registry_count]
    config.show.columns = [:fingerprint, :name, :pid, :parent_name, :parent_pid]

    # Sort columns in the following order.
    config.list.sorting = {:name => :asc}

    # Rename the following columns.
    config.columns[:pid].label = "PID"
    config.columns[:parent_name].label = "Parent Name"
    config.columns[:parent_pid].label = "Parent PID"
    config.columns[:process_file_count].label = "# Files"
    config.columns[:process_registry_count].label = "# Registries"

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "Process Details"

    # Disable eager loading of the following associations.
    config.list.columns.exclude :process_files, :process_registries
    config.show.columns.exclude :process_files, :process_registries

    # Include the following show actions.
    config.columns[:fingerprint].set_link :show, :controller => 'fingerprints', :parameters => {:parent_controller => 'os_processes'}
  end

  # Helper function to determine if the os_processes view should show
  # nested fingerprints.
  def check_for_nested_fingerprints
    if (params[:parent_controller] == "process_files" || params[:parent_controller] == "process_registries")
      @show_nested_fingerprints = true
    else
      @show_nested_fingerprints = false
    end
  end
end
