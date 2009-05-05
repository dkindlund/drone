class JobSourcesController < ApplicationController
  active_scaffold :job_source do |config|
    # Table Title
    config.list.label = "Job Sources"

    # Show the following columns in the specified order.
    config.list.columns = [:name, :protocol]

    # Sort columns in the following order.
    config.list.sorting = {:name => :asc}

    # Disable eager loading for the following attributes.
    config.columns[:jobs].includes = nil

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "Source Details"
  end
end
