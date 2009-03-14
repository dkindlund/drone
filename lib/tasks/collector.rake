# Data Collector Daemon
#
# Used for populating the rails application with new data from the RabbitMQ server.

namespace :collector do
  require 'event_collector'
  require 'md5'
  require 'guid'
 
  desc "Starts the collector daemon, in order to obtain updated data from the Honeyclient Manager"
  task :start => [:environment] do
    RAILS_DEFAULT_LOGGER.auto_flushing = true
    daemon = EventCollector.new
    daemon.start
  end

  desc "Stops the collector daemon"
  task :stop => [:environment] do
    RAILS_DEFAULT_LOGGER.auto_flushing = true
    daemon = EventCollector.new
    daemon.stop
  end

  desc "Tests the collector daemon, by sending sample data to the collector as if it were coming from the Honeyclient Manager"
  task :test => [:environment] do
    RAILS_DEFAULT_LOGGER.auto_flushing = true
    daemon = EventCollector.new
    # TODO: Need better testing, eventually.

    # Simulate host creation.
    host = {"host" =>
             {"ip"       => "10.0.0.1",
              "hostname" => "honeyclient1.foo.com"}}
    daemon.send('host.find_or_create', host)


    # Simulate client creation.
    quick_clone_name = MD5.hexdigest(Time.now.to_s).slice(0..25)
    snapshot_name    = MD5.hexdigest(quick_clone_name).slice(0..25)
    client = {"client" =>
               {"quick_clone_name" => quick_clone_name,
                "os"=>
                  {"name"          => "Windows XP Service Pack 2",
                   "version"       => "5.1.2600.2",
                   "short_name"    => "Microsoft Windows"},
                "application"=>
                  {"manufacturer"  => "Microsoft Corporation",
                   "version"       => "6.0.290.2180",
                   "short_name"    => "Internet Explorer"},
                "snapshot_name"    => snapshot_name,
                "client_status"=>
                  {"status"        => "created"},
                   "host"=>
                     {"ip"         => "10.0.0.1",
                      "hostname"   => "honeyclient1.foo.com"},
                "created_at"       => Time.now.iso8601.to_s}}

    # Specify that we want to create or reuse an existing client.
    daemon.send('client.find_or_create', client)

    # Simulate client status change to running.
    client = {"client" =>
               {"quick_clone_name" => quick_clone_name,
                "snapshot_name"    => snapshot_name,
                "client_status"=>
                  {"status"        => "running"}}}

    # Specify that we want to update an existing client and specifically
    # just update: client_status sub-hash.
    daemon.send('client.find_and_update.client_status', client)

    # Simulate a new job getting created.
    job_uuid = Guid.new.to_s
    job = {"job"=>
            {"job_source"  =>
              {"name"      => "proxy.foo.com",
               "protocol"  => "http"},
             "job_alerts"  =>
              [{"protocol" => "smtp",
                "address"  => "admin@foo.com"}],
             "urls"=>
              [{"priority" => 10,
                "url"      => "http://www.bar.com/",
                "url_status" => {"status" => "queued"}},
               {"priority" => 100,
                "url"      => "http://www.foo.com/",
                "url_status" => {"status" => "queued"}}],
             "uuid"=> job_uuid}}

    # Specify that we want to create a new job and don't try
    # to reuse: job, urls, or job_alerts sub-hashes.
    daemon.send('job.create.job.urls.job_alerts', job)

    # TODO: Simulate client obtaining a new job.
    #daemon.send('job.update.client', job)
    #daemon.send('client.update.job', job)

    # TODO: Simulate client visiting URLs in job.
    #daemon.send('job.update.urls', job)

    # TODO: Simulate client encountering a suspicious URL in a job.
    #daemon.send('job.update.urls', job)

    # Simulate client status change to suspended.
    client = {"client" =>
               {"quick_clone_name" => quick_clone_name,
                "snapshot_name"    => snapshot_name,
                "suspended_at"     => Time.now.iso8601.to_s,
                "client_status"=>
                  {"status"        => "suspended"}}}

    # Specify that we want to update an existing client and specifically
    # just update: client_status and suspended_at sub-hashes.
    daemon.send('client.find_and_update.client_status.suspended_at', client)

    # TODO: Delete these, eventually.
    #daemon.send('client.create', Client.find(:all))
    #daemon.send('job.create', Job.find(:all))
  end
  
end

