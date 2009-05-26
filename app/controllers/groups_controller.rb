class GroupsController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column if (Rails.env.production? || Rails.env.development?)
  before_filter :login_required
  before_filter :admin_required

  active_scaffold :groups do |config|
    # Table Title
    config.list.label = "Groups"

    # Show the following columns in the specified order.
    config.list.columns = [:name]

    # Sort columns in the following order.
    config.list.sorting = {:name => :asc}

    # Exclude the following actions.
    config.actions.exclude :show
  end

  protected

  def admin_required
    if (current_user.nil? || !current_user.has_role?(:admin))
      redirect_back_or_default('/')
    end
  end
end
