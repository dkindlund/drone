class ProcessFilesController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column, :show_export, :export if (Rails.env.production? || Rails.env.development?)
  before_filter :login_required

  active_scaffold :process_file do |config|
    # Table Title
    config.list.label = "Filesystem Activity"

    # Show the following columns in the specified order.
    config.list.columns = [:time_at, :os_process, :event, :name, :file_content]
    config.show.columns = [:time_at, :os_process, :event, :name, :file_content]

    # Sort columns in the following order.
    config.list.sorting = {:time_at => :desc}

    # Rename the following columns.
    config.columns[:os_process].label = "Process Name"
    config.columns[:time_at].label = "When"
    config.columns[:name].label = "File Name"
    config.columns[:file_content].label = "File Content"

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "Filesystem Activity Details"

    # Include the following show actions.
    config.columns[:os_process].set_link :show, :controller => 'os_processes', :parameters => {:parent_controller => 'process_files'}
    config.columns[:file_content].set_link :show, :controller => 'file_contents', :parameters => {:parent_controller => 'process_files'}

    # Add export options.
    config.actions.add :export
    config.export.columns = [:time_at, :os_process, :event, :name, :file_content]
    config.export.force_quotes = true
    config.export.allow_full_download = true
  end
end
