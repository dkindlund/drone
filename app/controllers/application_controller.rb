# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include SslRequirement
  include AuthenticatedSystem
  # You can move this into a different controller, if you wish.  This module gives you the require_role helpers, and others.
  include RoleRequirementSystem
  include ExceptionNotifiable

  ActiveScaffold.set_defaults do |config|
    config.security.default_permission = false
  end

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  # Make all access denied calls redirect to login path.
  def access_denied
    alias new_session_path login_path
    super
  end
end
