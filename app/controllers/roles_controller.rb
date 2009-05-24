class RolesController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column if (Rails.env.production? || Rails.env.development?)
  before_filter :login_required

  active_scaffold :roles do |config|
    # Table Title
    config.list.label = "Roles"

    # Show the following columns in the specified order.
    config.list.columns = [:name, :description]

    # Sort columns in the following order.
    config.list.sorting = {:name => :asc}

    # Exclude the following actions.
    config.actions.exclude :show
  end
end
