class DashboardController < ApplicationController
  ssl_required :index if (Rails.env.production? || Rails.env.development?)
  before_filter :login_required

  def index
  end
end
