class HostsController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column if (Rails.env.production? || Rails.env.development?)
  before_filter :login_required

  active_scaffold :host do |config|
    # Table Title
    config.list.label = "VMware ESX Hosts"

    # Show the following columns in the specified order.
    config.list.columns = [:hostname, :ip, :created_at, :updated_at]
    config.show.columns = [:hostname, :ip, :created_at, :updated_at]

    # Sort columns in the following order.
    config.list.sorting = {:hostname => :asc}

    # Disable eager loading for the following attributes.
    config.columns[:clients].includes = nil

    # Rename the following columns.
    config.columns[:ip].label = "IP Address"
    config.columns[:created_at].label = "Created"
    config.columns[:updated_at].label = "Updated"

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "Host Details"
  end
end
