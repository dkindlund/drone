# Data Collector Daemon
#
# Used for populating the rails application with new data from the RabbitMQ server.

namespace :collector do
  require 'event_collector'
 
  desc "Starts the collector daemon, in order to obtain updated data from the Honeyclient Manager"
  task :start => [:environment] do
    daemon = EventCollector.new
    daemon.start
  end

  desc "Stops the collector daemon"
  task :stop => [:environment] do
    daemon = EventCollector.new
    daemon.stop
  end

  desc "Tests the collector daemon, by sending sample data to the collector as if it were coming from the Honeyclient Manager"
  task :test => [:environment] do
    daemon = EventCollector.new
    daemon.test
  end
  
end

