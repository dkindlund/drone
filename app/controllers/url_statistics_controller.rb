class UrlStatisticsController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column, :show_export, :export if (Rails.env.production? || Rails.env.development?)
  before_filter :login_required
  before_filter :admin_required

  active_scaffold :url_statistic do |config|
    # Table Title
    config.list.label = "URL Statistics"

    # Show the following columns in the specified order.
    config.list.columns = [:url_status, :count, :created_at, :updated_at]
    config.show.columns = [:url_status, :count, :created_at, :updated_at]

    # Rename the following columns.
    config.columns[:url_status].label = "URL Status"
    config.columns[:created_at].label = "From"
    config.columns[:updated_at].label = "To"

    # Add export options.
    config.actions.add :export
    config.export.columns = [:url_status, :count, :created_at, :updated_at]
    config.export.force_quotes = true
    config.export.allow_full_download = true

    # Support ATOM Format
    config.formats << :atom
  end

  protected
  def list_respond_to_atom
    @url_statistics = UrlStatistic.find(:all, :order => 'url_statistics.updated_at DESC', :limit => Configuration.find_retry(:name => "atom.max_entries", :namespace => "UrlStatistic").to_i)

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
