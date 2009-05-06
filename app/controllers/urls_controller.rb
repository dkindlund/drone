class UrlsController < ApplicationController
  active_scaffold :url do |config|
    # Table Title
    config.list.label = "URLs"

    # Add virtual field: job_source
    config.columns << :job_source

    # Show the following columns in the specified order.
    config.list.columns = [:job, :job_source, :url, :priority, :url_status, :time_at, :client, :fingerprint, :created_at, :updated_at]
    config.show.columns = [:job, :job_source, :url, :priority, :url_status, :time_at, :client, :fingerprint, :created_at, :updated_at]

    # Sort columns in the following order.
    config.list.sorting = {:time_at => :desc}

    # Rename the following columns.
    config.columns[:job].label = "Job ID"
    config.columns[:job_source].label = "Job Source"
    config.columns[:url].label = "URL"
    config.columns[:url_status].label = "Status"
    config.columns[:time_at].label = "Visited"
    config.columns[:created_at].label = "Created"
    config.columns[:updated_at].label = "Updated"

    # Make sure the url_status column is searchable.
    config.columns[:url_status].search_sql = 'url_statuses.status'
    config.search.columns << :url_status

    # Make sure the fingerprint column is searchable.
    config.columns[:fingerprint].search_sql = 'fingerprints.checksum'
    config.search.columns << :fingerprint

    # Make sure the job column is searchable.
    config.columns[:job].search_sql = 'jobs.uuid'
    config.search.columns << :job

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "URL Details"

    # Include the following show actions.
    config.columns[:fingerprint].set_link :show, :controller => 'fingerprints', :parameters => {:parent_controller => 'urls'}
    config.columns[:client].set_link :show, :controller => 'clients', :parameters => {:parent_controller => 'urls'}
    config.columns[:job].set_link :show, :controller => 'jobs', :parameters => {:parent_controller => 'urls'}
    # TODO: Should provide this next one as a tooltip.
    # TODO: ? config.columns[:url_status].set_link :show, :controller => 'url_statuses', :parameters => {:parent_controller => 'urls'}

    # Disable eager loading of the following associations.
    # TODO: Check if this is needed for performance reasons; if we enable it, be sure to remove the job column searchability.
    #config.columns[:job].includes = nil
    config.columns[:client].includes = nil
    # TODO: Check if this is needed for performance reasons; if we enable it, be sure to remove the fingerprint column searchability.
    #config.columns[:fingerprint].includes = nil
  end
end
