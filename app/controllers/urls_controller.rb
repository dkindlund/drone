class UrlsController < ApplicationController
  active_scaffold :url do |config|
    # Table Title
    config.list.label = "URLs"

    # Show the following columns in the specified order.
    config.list.columns = [:job, :url, :priority, :url_status, :time_at, :client, :fingerprint, :created_at, :updated_at]

    # Sort columns in the following order.
    config.list.sorting = {:time_at => :desc}

    # Rename the following columns.
    config.columns[:job].label = "Job ID"
    config.columns[:url].label = "URL"
    config.columns[:url_status].label = "Status"
    config.columns[:time_at].label = "Visited"
    config.columns[:created_at].label = "Created"
    config.columns[:updated_at].label = "Updated"

    # Make sure the url_status column is searchable.
    config.columns[:url_status].search_sql = 'url_statuses.status'
    config.search.columns << :url_status

    # Exclude the following actions.
    config.actions.exclude :show

    # Include the following show actions.
    #config.columns[:fingerprint].set_link :show, :controller => 'fingerprints', :parameters => {:parent_controller => 'urls'}
  end
end
