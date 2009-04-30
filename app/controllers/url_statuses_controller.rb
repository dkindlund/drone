class UrlStatusesController < ApplicationController
  active_scaffold :url_status do |config|
    # Show the following columns in the specified order.
    config.list.columns = [:status, :description]

    # Disable eager loading for the following attributes.
    config.columns[:urls].includes = nil
  end
end
