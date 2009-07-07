class UrlStatusesController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column, :show_export, :export if (Rails.env.production? || Rails.env.development?)
  before_filter :login_required

  active_scaffold :url_status do |config|
    # Table Title
    config.list.label = "URL Status Types"

    # Show the following columns in the specified order.
    config.list.columns = [:status, :description]

    # Sort columns in the following order.
    config.list.sorting = {:status => :asc}

    # Disable eager loading for the following attributes.
    config.columns[:urls].includes = nil

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "URL Status Details"

    # Add export options.
    config.actions.add :export
    config.export.columns = [:status, :description]
    config.export.force_quotes = true
    config.export.allow_full_download = true

    # Support ATOM Format
    config.formats << :atom
  end

  protected
  def list_respond_to_atom
    @url_statuses = UrlStatus.find(:all, :order => 'url_statuses.id DESC', :limit => Configuration.find_retry(:name => "atom.max_entries", :namespace => "UrlStatus").to_i)

    respond_to do |format|
      format.atom
    end
  end
end
