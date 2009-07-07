class ConfigurationsController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column, :show_export, :export if (Rails.env.production? || Rails.env.development?)
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

    # Use field searching.
    config.actions.swap :search, :field_search

    # Add export options.
    config.actions.add :export
    config.export.columns = [:namespace, :name, :value, :description, :default_value]
    config.export.force_quotes = true
    config.export.allow_full_download = true

    # Support ATOM Format
    config.formats << :atom
  end

  protected
  # TODO: We may want to include an updated_at timestamp, in order to track when configuration settings are changed.
  def list_respond_to_atom
    @configurations = Configuration.find(:all, :order => 'configurations.id DESC', :limit => Configuration.find_retry(:name => "atom.max_entries", :namespace => "Configuration").to_i)

    respond_to do |format|
      format.atom
    end
  end

  def admin_required
    if (current_user.nil? || !current_user.has_role?(:admin))
      redirect_back_or_default('/')
    end
  end
end
