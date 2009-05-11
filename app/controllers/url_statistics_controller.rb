class UrlStatisticsController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column
  before_filter :login_required

  active_scaffold :url_statistic do |config|
    # Table Title
    config.list.label = "URL Statistics"
  end
end
