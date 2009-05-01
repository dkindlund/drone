class JobsController < ApplicationController
  active_scaffold :job do |config|
    # Table Title
    config.list.label = "Jobs"

    # Show the following columns in the specified order.
    config.list.columns = [:uuid, :created_at, :updated_at, :completed_at, :job_source, :job_alerts, :url_count]

    # Sort columns in the following order.
    config.list.sorting = {:updated_at => :desc}

    # Rename the following columns.
    config.columns[:uuid].label = "ID"
    config.columns[:created_at].label = "Created"
    config.columns[:updated_at].label = "Updated"
    config.columns[:completed_at].label = "Completed"
    config.columns[:job_source].label = "Source"
    config.columns[:job_alerts].label = "Notifiers"
    config.columns[:url_count].label = "# URLs"

    # Disable eager loading.
    # TODO: config.list.columns.exclude :urls
  end
end
