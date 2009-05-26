class ConfigurationsController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column if (Rails.env.production? || Rails.env.development?)
  before_filter :login_required
  before_filter :admin_required

  active_scaffold :configuration do |config|
    # Table Title
    config.list.label = "Configurations"

    # Show the following columns in the specified order.
    config.list.columns = [:namespace, :name, :value, :description, :default_value]
    config.show.columns = [:namespace, :name, :value, :description, :default_value]

    # Sort columns in the following order.
    config.list.sorting = [{:namespace => :asc}, {:name => :asc}, {:value => :asc}]

    # Rename the following columns.
    config.columns[:default_value].label = "Default Value"

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "Configuration Details"
  end

  protected

  def admin_required
    if (current_user.nil? || !current_user.has_role?(:admin))
      redirect_back_or_default('/')
    end
  end
end
