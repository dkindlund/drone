# Global Authorization Helper
#
# Designed to provide all models with a consistent security model.
#
# See: http://wiki.github.com/activescaffold/active_scaffold/security

module AuthorizationHelper

  # By default, allow all authenticated users read-only access
  # to the interface.
  def authorized_for_read?
    return true
  end
end
