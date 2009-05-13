# Notifier Daemon
#
# Used for notifying users when jobs are complete.

namespace :notifier do
  require 'event_notifier'
 
  desc "Starts the notifier daemon, in order to notify users when jobs are complete by the Honeyclient Manager"
  task :start => [:environment] do
    RAILS_DEFAULT_LOGGER.auto_flushing = true
    daemon = EventNotifier.new
    daemon.start
  end

  desc "Stops the notifier daemon"
  task :stop => [:environment] do
    RAILS_DEFAULT_LOGGER.auto_flushing = true
    daemon = EventNotifier.new
    daemon.stop
  end
end

