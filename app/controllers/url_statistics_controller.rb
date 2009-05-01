class UrlStatisticsController < ApplicationController
  active_scaffold :url_statistic do |config|
    # Table Title
    config.list.label = "URL Statistics"
  end
end
