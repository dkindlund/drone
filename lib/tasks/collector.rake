# Data Collector Daemon
#
# Used for populating the rails application with new data from the RabbitMQ server.

namespace :collector do
  require 'event_collector'
  require 'md5'
  require 'sha1'
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
    # TODO: Need better validation, eventually.

    # Simulate host creation.
    host = {"host"       =>
             {"ip"       => "10.0.0.1",
              "hostname" => "honeyclient1.foo.com"}}
    daemon.send('host.find_or_create', host)


    # Simulate client creation.
    quick_clone_name = MD5.hexdigest(Time.now.to_s).slice(0..25)
    snapshot_name    = MD5.hexdigest(quick_clone_name).slice(0..25)
    client = {"client"             =>
               {"quick_clone_name" => quick_clone_name,
                "os"               =>
                  {"name"          => "Windows XP Service Pack 2",
                   "version"       => "5.1.2600.2",
                   "short_name"    => "Microsoft Windows"},
                "application"      =>
                  {"manufacturer"  => "Microsoft Corporation",
                   "version"       => "6.0.290.2180",
                   "short_name"    => "Internet Explorer"},
                "snapshot_name"    => snapshot_name,
                "client_status"    =>
                  {"status"        => "created"},
                "host"             =>
                  {"ip"            => "10.0.0.1",
                   "hostname"      => "honeyclient1.foo.com"},
                "created_at"       => Time.now.iso8601.to_s}}

    # Specify that we want to create or reuse an existing client.
    daemon.send('client.find_or_create', client)

    # Simulate client status change to running.
    client = {"client"             =>
               {"quick_clone_name" => quick_clone_name,
                "snapshot_name"    => snapshot_name,
                "client_status"    =>
                  {"status"        => "running"}}}

    # Specify that we want to update an existing client and specifically
    # just update: client_status sub-hash.
    daemon.send('client.find_and_update.client_status', client)

    # Simulate a new job getting created.
    job_uuid = Guid.new.to_s
    job = {"job"             =>
            {"job_source"    =>
              {"name"        => "proxy.foo.com",
               "protocol"    => "http"},
             "job_alerts"    =>
              [{"protocol"   => "smtp",
                "address"    => "admin@foo.com"}],
             "urls"          =>
              [{"priority"   => 10,
                "url"        => "http://www.bar.com/",
                "url_status" => {"status" => "queued"}},
               {"priority"   => 50,
                "url"        => "http://www.baz.com/",
                "url_status" => {"status" => "queued"}},
               {"priority"   => 100,
                "url"        => "http://www.foo.com/",
                "url_status" => {"status" => "queued"}}],
             "uuid"          => job_uuid}}

    # Specify that we want to create a new job and don't try
    # to reuse: job, urls, or job_alerts sub-hashes.
    daemon.send('job.create.job.urls.job_alerts', job)

    # Simulate client obtaining a new job.
    job = {"job"                  =>
            {"uuid"               => job_uuid,
             "client"             => 
              {"quick_clone_name" => quick_clone_name,
               "snapshot_name"    => snapshot_name}}}

    # Specify that we want to update an existing job and specifically
    # just update: client sub-hash.
    daemon.send('job.find_and_update.client', job)

    # Simulate client visiting URLs in job.
    job = {"job"             =>
            {"uuid"          => job_uuid,
             "urls"          =>
              [{"time_at"    => Time.now.to_f,
                "url"        => "http://www.foo.com/",
                "url_status" => {"status" => "visited"}},
               {"time_at"    => Time.now.to_f,
                "url"        => "http://www.baz.com/",
                "url_status" => {"status" => "timed_out"}}]}}

    # Specify that we want to update an existing job and specifically
    # just update: urls array of sub-hashes.
    daemon.send('job.find_and_update.urls.url_status.time_at', job)

    # Simulate client encountering a suspicious URL in a job.
    time_at = Time.now.to_f
    job = {"job"             =>
            {"uuid"          => job_uuid,
             "urls"          =>
              [{"time_at"    => time_at,
                "url"        => "http://www.bar.com/",
                "url_status" => {"status" => "suspicious"}}]}}
    # Specify that we want to update an existing job and specifically
    # just update: urls array of sub-hashes.
    daemon.send('job.find_and_update.urls.url_status.time_at', job)

    # Simulate a new fingerprint getting created.
    checksum = MD5.hexdigest(Time.now.to_s)
    fingerprint = {"fingerprint"            =>
                   {"checksum"              => checksum,
                    "url"                   =>
                     # XXX: We assume there are always unique (url,time_at) entries and
                     # no such duplicates occur.
                     {"url"                 => "http://www.bar.com/",
                      "time_at"             => time_at},
                    "os_processes"          =>
                     [{"name"               => 'C:\Program Files\Internet Explorer\iexplore.exe',
                       "pid"                => 9123,
                       "process_files"      => 
                        [{"name"            => 'C:\WINDOWS\fheueyw.exe',
                          "event"           => "Write",
                          "time_at"         => time_at,
                          "file_content"    => 
                           {"md5"           => MD5.hexdigest(checksum),
                            "sha1"          => SHA1.hexdigest(checksum),
                            "size"          => 23847,
                            "mime_type"     => "application/x-ms-dos-executable"}},
                         {"name"            => 'C:\WINDOWS\notepad.exe',
                          "event"           => "Delete",
                          "time_at"         => time_at}],
                       "process_registries" =>
                        [{"name"            => 'HKLM\SYSTEM\ControlSet001\Control\SecurityProviders',
                          "event"           => "SetValueKey",
                          "value_name"      => "SecurityProviders",
                          "value_type"      => "REG_SZ",
                          "value"           => "msapsspc.dll, schannel.dll, digest.dll, msnsspc.dll, digeste.dll",
                          "time_at"         => time_at},
                         {"name"            => 'HKLM\SYSTEM\ControlSet002\Control\SecurityProviders',
                          "event"           => "SetValueKey",
                          "value_name"      => "SecurityProviders",
                          "value_type"      => "REG_SZ",
                          "value"           => "msapsspc.dll, schannel.dll, digest.dll, msnsspc.dll, digeste.dll",
                          "time_at"         => time_at}]},
                      {"name"               => 'C:\WINDOWS\fheueyw.exe',
                       "pid"                => 7363,
                       "parent_name"        => 'C:\Program Files\Internet Explorer\iexplore.exe',
                       "parent_pid"         => 9123}]}}
    # Specify that we want to create a new fingerprint and don't try
    # to reuse: fingerprint, os_processes, process_files, or process_registries sub-hashes.
    daemon.send('fingerprint.create.fingerprint.os_processes.process_files.process_registries', fingerprint)

    # Simulate client status change to suspicious.
    client = {"client"             =>
               {"quick_clone_name" => quick_clone_name,
                "snapshot_name"    => snapshot_name,
                "suspended_at"     => Time.now.iso8601.to_s,
                "client_status"    =>
                  {"status"        => "suspicious"}}}

    # Specify that we want to update an existing client and specifically
    # just update: client_status and suspended_at sub-hashes.
    daemon.send('client.find_and_update.client_status.suspended_at', client)
  end
end

