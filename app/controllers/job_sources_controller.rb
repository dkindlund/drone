class JobSourcesController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column if (Rails.env.production? || Rails.env.development?)
  before_filter :login_required

  active_scaffold :job_source do |config|
    # Table Title
    config.list.label = "Job Sources"

    # Show the following columns in the specified order.
    config.list.columns = [:name, :protocol]
    config.show.columns = [:name, :protocol]

    # Sort columns in the following order.
    config.list.sorting = {:name => :asc}

    # Disable eager loading for the following attributes.
    config.columns[:jobs].includes = nil

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "Source Details"
  end
end
