class ProcessFilesController < ApplicationController
  active_scaffold :process_file do |config|
    # Table Title
    config.list.label = "Filesystem Activity"

    # Show the following columns in the specified order.
    config.list.columns = [:time_at, :os_process, :event, :name, :file_content]

    # Sort columns in the following order.
    config.list.sorting = {:time_at => :desc}

    # Rename the following columns.
    config.columns[:os_process].label = "Process Name"
    config.columns[:time_at].label = "When"
    config.columns[:name].label = "File Name"
    config.columns[:file_content].label = "File Content"
  end
end
