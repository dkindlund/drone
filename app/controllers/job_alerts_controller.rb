class JobAlertsController < ApplicationController
  active_scaffold :job_alert do |config|
    # Table Title
    config.list.label = "Job Notifiers"

    # Show the following columns in the specified order.
    config.list.columns = [:job, :address, :protocol]
    config.show.columns = [:job, :address, :protocol]

    # Rename the following columns.
    config.columns[:job].label = "Job ID"

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "Notification Details"

    # Include the following show actions.
    config.columns[:job].set_link :show, :controller => 'jobs', :parameters => {:parent_controller => 'job_alerts'}
  end
end
