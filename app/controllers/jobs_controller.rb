class JobsController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column
  before_filter :login_required

  active_scaffold :job do |config|
    # Table Title
    config.list.label = "Jobs"

    # Show the following columns in the specified order.
    config.list.columns = [:uuid, :created_at, :updated_at, :completed_at, :job_source, :job_alerts, :url_count]
    config.show.columns = [:uuid, :created_at, :updated_at, :completed_at, :job_source, :job_alerts, :url_count]

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

    # Make sure the job_source column is searchable.
    config.columns[:job_source].search_sql = 'job_sources.name'
    config.search.columns << :job_source

    # Make sure the job_alerts column is searchable.
    config.columns[:job_alerts].search_sql = "CONCAT(job_alerts.protocol, ':', job_alerts.address)"
    config.search.columns << :job_alerts

    # Disable eager loading.
    config.list.columns.exclude :urls

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "Job Details"

    # Include the following show actions.
    config.columns[:job_source].set_link :show, :controller => 'job_sources', :parameters => {:parent_controller => 'jobs'}

    # Show the associated links.
    config.columns[:job_alerts].actions_for_association_links = [:show]
  end
end
