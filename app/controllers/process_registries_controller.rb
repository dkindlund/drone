class ProcessRegistriesController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column if (Rails.env.production? || Rails.env.development?)
  before_filter :login_required

  active_scaffold :process_registry do |config|
    # Table Title
    config.list.label = "Registry Activity"

    # Show the following columns in the specified order.
    config.list.columns = [:time_at, :os_process, :event, :name, :value_name, :value_type, :value]
    config.show.columns = [:time_at, :os_process, :event, :name, :value_name, :value_type, :value]

    # Sort columns in the following order.
    config.list.sorting = {:time_at => :desc}

    # Rename the following columns.
    config.columns[:os_process].label = "Process Name"
    config.columns[:time_at].label = "When"
    config.columns[:name].label = "Registry Name"
    config.columns[:value_name].label = "Value Name"
    config.columns[:value_type].label = "Value Type"

    # Make sure the value column is searchable.
    config.columns[:value].search_sql = 'process_registries.value'
    config.search.columns << :value

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "Registry Activity Details"

    # Include the following show actions.
    config.columns[:os_process].set_link :show, :controller => 'os_processes', :parameters => {:parent_controller => 'process_registries'}
  end
end
