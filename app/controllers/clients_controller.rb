class ClientsController < ApplicationController
  active_scaffold :client do |config|
    # Table Title
    config.list.label = "Client List"

    # Show the following columns in the specified order.
    config.list.columns = [:id, :quick_clone_name, :snapshot_name, :client_status, :job_count, :created_at, :suspended_at, :host, :os, :application]
    config.show.columns = [:id, :quick_clone_name, :snapshot_name, :client_status, :job_count, :created_at, :suspended_at, :updated_at, :host, :os, :application]

    # Sort columns in the following order.
    config.list.sorting = [{:suspended_at => :desc}, {:updated_at => :desc}]

    # Rename the following columns.
    config.columns[:id].label = "ID"
    config.columns[:quick_clone_name].label = "VM Name"
    config.columns[:snapshot_name].label = "Snapshot Name"
    config.columns[:client_status].label = "Status"
    config.columns[:job_count].label = "# Jobs"
    config.columns[:created_at].label = "Created"
    config.columns[:suspended_at].label = "Suspended"
    config.columns[:updated_at].label = "Updated"
    config.columns[:os].label = "OS"

    # Make sure the client_status column is searchable.
    config.columns[:client_status].search_sql = 'client_statuses.status'
    config.search.columns << :client_status

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "Client Details"

    # Include the following show actions.
    config.columns[:host].set_link :show, :controller => 'hosts', :parameters => {:parent_controller => 'clients'}
    config.columns[:os].set_link :show, :controller => 'os', :parameters => {:parent_controller => 'clients'}
    config.columns[:application].set_link :show, :controller => 'applications', :parameters => {:parent_controller => 'clients'}
    # TODO: Should provide this next one as a tooltip.
    # TODO: ? config.columns[:client_status].set_link :show, :controller => 'client_statuses', :parameters => {:parent_controller => 'clients'}

    # Nest the following associations.
    config.nested.add_link("URLs Processed", [:urls])
  end
end
