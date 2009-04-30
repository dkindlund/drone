class JobSourcesController < ApplicationController
  active_scaffold :job_source do |config|
    # Show the following columns in the specified order.
    config.list.columns = [:name, :protocol]

    # Disable eager loading for the following attributes.
    config.columns[:jobs].includes = nil
  end
end
