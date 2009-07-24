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

  desc "Starts the notifier daemon (detached), in order to notify users when jobs are complete by the Honeyclient Manager"
  task :start_detached, :configkey, :needs => [:environment] do |t,args|
    RAILS_DEFAULT_LOGGER.auto_flushing = true
    # XXX: This will need to be configurable, if we want to run multiple instances.
    #abort "Missing config key. Run as 'rake notifier:start_detached['CONFIGKEY']'" unless args.configkey
    # XXX: CONFIGKEY entry must be in 'config/theman.yml'.
    daemon = EventNotifier.new
    # XXX: This will need to be configurable, if we want to run multiple instances.
    #daemon.configkey = args.configkey
    daemon.configkey = 'notifier'
    daemon.start(true)
  end
  
  desc "Stops the notifier daemon (detached)"
  task :stop_detached, :configkey, :needs => [:environment] do |t,args|
    RAILS_DEFAULT_LOGGER.auto_flushing = true
    # XXX: This will need to be configurable, if we want to run multiple instances.
    #abort "Missing config key. Run as 'rake notifier:stop_detached['CONFIGKEY']'" unless args.configkey
    # XXX: CONFIGKEY entry must be in 'config/theman.yml'.
    daemon = EventNotifier.new
    # XXX: This will need to be configurable, if we want to run multiple instances.
    #daemon.configkey = args.configkey
    daemon.configkey = 'notifier'
    daemon.stop(true)
  end
end

