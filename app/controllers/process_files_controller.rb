class ProcessFilesController < ApplicationController
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
  end
end
