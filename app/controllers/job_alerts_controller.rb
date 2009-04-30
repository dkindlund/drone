class JobAlertsController < ApplicationController
  active_scaffold :job_alert do |config|
    # Show the following columns in the specified order.
    config.list.columns = [:job, :address, :protocol]

    # Rename the following columns.
    config.columns[:job].label = "Job ID"
  end
end
