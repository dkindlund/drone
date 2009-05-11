class DashboardController < ApplicationController
  ssl_required :index
  before_filter :login_required

  def index
  end
end
