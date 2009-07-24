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
  
  desc "Starts the collector daemon (detached), in order to obtain updated data from the Honeyclient Manager"
  task :start_detached, :configkey, :needs => [:environment] do |t,args|
    RAILS_DEFAULT_LOGGER.auto_flushing = true
    abort "Missing config key. Run as 'rake collector:start_detached['CONFIGKEY']'" unless args.configkey
    daemon = EventCollector.new
    daemon.configkey = args.configkey
    daemon.start('',true)
  end
  
  desc "Stops the collector daemon (detached)"
  task :stop_detached, :configkey, :needs => [:environment] do |t,args|
    RAILS_DEFAULT_LOGGER.auto_flushing = true
    abort "Missing config key. Run as 'rake collector:stop_detached['CONFIGKEY']'" unless args.configkey
    daemon = EventCollector.new
    daemon.configkey = args.configkey
    daemon.stop('',true)
  end
  
  desc "Stops the collector daemon"
  task :stop => [:environment] do
    RAILS_DEFAULT_LOGGER.auto_flushing = true
    daemon = EventCollector.new
    daemon.stop
  end

  # XXX: Possible deprecation.
  desc "Tests the collector daemon, by sending sample data to the collector as if it were coming from the Honeyclient Manager"
  task :test => [:environment] do
    RAILS_DEFAULT_LOGGER.auto_flushing = true
    daemon = EventCollector.new

    # Simulate host creation.
    host = {"host"       =>
             {"ip"       => "10.0.0.3",
              "hostname" => "honeyclient3.foo.com"}}
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
                  {"ip"            => "10.0.0.3",
                   "hostname"      => "honeyclient3.foo.com"},
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

  desc "Tests the collector daemon, by sending sample data to the collector as if it were coming from an internal source"
  task :test_internal => [:environment] do
    RAILS_DEFAULT_LOGGER.auto_flushing = true
    collector = EventCollector.new

    # Simulate host creation.
    host = {"host"       =>
             {"ip"       => "10.0.0.3",
              "hostname" => "honeyclient3.foo.com"}}
    result = collector.test_send_event('host.find_or_create', host)
    host_id = result["host"].id

    # Simulate client creation.
    quick_clone_name = MD5.hexdigest(Time.now.to_s).slice(0..25)
    snapshot_name    = MD5.hexdigest(quick_clone_name).slice(0..25)
    time_at          = Time.now.utc
    client = {"client"             =>
               {"quick_clone_name" => quick_clone_name,
                "os"               =>
                 {"name"           => "Windows XP Service Pack 2",
                  "version"        => "5.1.2600.2",
                  "short_name"     => "Microsoft Windows"},
                "application"      =>
                 {"manufacturer"   => "Microsoft Corporation",
                  "version"        => "6.0.290.2180",
                  "short_name"     => "Internet Explorer"},
                "snapshot_name"    => snapshot_name,
                "client_status"    =>
                 {"status"         => "created"},
                "host"             =>
                 {"ip"             => "10.0.0.3",
                  "hostname"       => "honeyclient3.foo.com"},
                "created_at"       => time_at.iso8601.to_s}}

    # Specify that we want to create or reuse an existing client.
    result = collector.test_send_event('client.find_or_create', client)
    client_id = result["client"].id

    # Simulate client status change to running.
    client = {"client"             =>
               {"quick_clone_name" => quick_clone_name,
                "snapshot_name"    => snapshot_name,
                "client_status"    =>
                 {"status"         => "running"}}}

    # Specify that we want to update an existing client and specifically
    # just update: client_status sub-hash.
    result = collector.test_send_event('client.find_and_update.client_status', client)

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
    result = collector.test_send_event('job.create.job.urls.job_alerts', job)
    job_id = result["job"].id

    # Simulate client obtaining a new job.
    job = {"job"                  =>
            {"uuid"               => job_uuid,
             "client"             => 
              {"quick_clone_name" => quick_clone_name,
               "snapshot_name"    => snapshot_name}}}

    # Specify that we want to update an existing job and specifically
    # just update: client sub-hash.
    result = collector.test_send_event('job.find_and_update.client', job)

    # Simulate client visiting URLs in job.
    time_at = Time.now.utc
    job = {"job"             =>
            {"uuid"          => job_uuid,
             "urls"          =>
              [{"time_at"    => time_at.to_f,
                "url"        => "http://www.foo.com/",
                "url_status" => {"status" => "visited"}},
               {"time_at"    => time_at.to_f,
                "url"        => "http://www.baz.com/",
                "url_status" => {"status" => "timed_out"}}]}}

    # Specify that we want to update an existing job and specifically
    # just update: urls array of sub-hashes.
    result = collector.test_send_event('job.find_and_update.urls.url_status.time_at', job)

    # Simulate client encountering a suspicious URL in a job.
    time_at = Time.now.utc
    job = {"job"             =>
            {"uuid"          => job_uuid,
             "completed_at"  => time_at.iso8601.to_s,
             "urls"          =>
              [{"time_at"    => time_at.to_f,
                "url"        => "http://www.bar.com/",
                "url_status" => {"status" => "suspicious"}}]}}
    # Specify that we want to update an existing job and specifically
    # just update: urls array of sub-hashes.
    result = collector.test_send_event('job.find_and_update.completed_at.urls.url_status.time_at', job)

    # Simulate a new fingerprint getting created.
    checksum = MD5.hexdigest(Time.now.to_s)
    fingerprint = {"fingerprint"            =>
                   {"checksum"              => checksum,
                    "url"                   =>
                     # XXX: We assume there are always unique (url,time_at) entries and
                     # no such duplicates occur.
                     {"url"                 => "http://www.bar.com/",
                      "time_at"             => time_at.to_f},
                    "os_processes"          =>
                     [{"name"               => 'C:\Program Files\Internet Explorer\iexplore.exe',
                       "pid"                => 9123,
                       "process_files"      => 
                        [{"name"            => 'C:\WINDOWS\fheueyw.exe',
                          "event"           => "Write",
                          "time_at"         => time_at.to_f,
                          "file_content"    => 
                           {"md5"           => MD5.hexdigest(checksum),
                            "sha1"          => SHA1.hexdigest(checksum),
                            "size"          => 23847,
                            "mime_type"     => "application/x-ms-dos-executable"}},
                         {"name"            => 'C:\WINDOWS\notepad.exe',
                          "event"           => "Delete",
                          "time_at"         => time_at.to_f}],
                       "process_registries" =>
                        [{"name"            => 'HKLM\SYSTEM\ControlSet001\Control\SecurityProviders',
                          "event"           => "SetValueKey",
                          "value_name"      => "SecurityProviders",
                          "value_type"      => "REG_SZ",
                          "value"           => "msapsspc.dll, schannel.dll, digest.dll, msnsspc.dll, digeste.dll",
                          "time_at"         => time_at.to_f},
                         {"name"            => 'HKLM\SYSTEM\ControlSet002\Control\SecurityProviders',
                          "event"           => "SetValueKey",
                          "value_name"      => "SecurityProviders",
                          "value_type"      => "REG_SZ",
                          "value"           => "msapsspc.dll, schannel.dll, digest.dll, msnsspc.dll, digeste.dll",
                          "time_at"         => time_at.to_f}]},
                      {"name"               => 'C:\WINDOWS\fheueyw.exe',
                       "pid"                => 7363,
                       "parent_name"        => 'C:\Program Files\Internet Explorer\iexplore.exe',
                       "parent_pid"         => 9123}]}}
    # Specify that we want to create a new fingerprint and don't try
    # to reuse: fingerprint, os_processes, process_files, or process_registries sub-hashes.
    result = collector.test_send_event('fingerprint.create.fingerprint.os_processes.process_files.process_registries', fingerprint)
    fingerprint_id = result["fingerprint"].id

    # Simulate client status change to suspicious.
    client = {"client"             =>
               {"quick_clone_name" => quick_clone_name,
                "snapshot_name"    => snapshot_name,
                "suspended_at"     => time_at.iso8601.to_s,
                "client_status"    =>
                  {"status"        => "suspicious"}}}

    # Specify that we want to update an existing client and specifically
    # just update: client_status and suspended_at sub-hashes.
    result = collector.test_send_event('client.find_and_update.client_status.suspended_at', client)
  end

  namespace :high do
    desc "Starts the high-priority collector daemon, in order to obtain updated data from the Honeyclient Manager"
    task :start => [:environment] do
      RAILS_DEFAULT_LOGGER.auto_flushing = true
      daemon = EventCollector.new
      daemon.start('high')
    end

    desc "Stops the high-priority collector daemon"
    task :stop => [:environment] do
      RAILS_DEFAULT_LOGGER.auto_flushing = true
      daemon = EventCollector.new
      daemon.stop('high')
    end

    desc "Starts the high-priority collector daemon (detached), in order to obtain updated data from the Honeyclient Manager"
    task :start_detached, :configkey, :needs => [:environment] do |t,args|
      RAILS_DEFAULT_LOGGER.auto_flushing = true
      # XXX: This will need to be configurable, if we want to run multiple instances.
      #abort "Missing config key. Run as 'rake collector:high:start_detached['CONFIGKEY']'" unless args.configkey
      # XXX: CONFIGKEY entry must be in 'config/theman.yml'.
      daemon = EventCollector.new
      # XXX: This will need to be configurable, if we want to run multiple instances.
      #daemon.configkey = args.configkey
      daemon.configkey = 'collector_high'
      daemon.start('high',true)
    end
  
    desc "Stops the high-priority collector daemon (detached)"
    task :stop_detached, :configkey, :needs => [:environment] do |t,args|
      RAILS_DEFAULT_LOGGER.auto_flushing = true
      # XXX: This will need to be configurable, if we want to run multiple instances.
      #abort "Missing config key. Run as 'rake collector:high:stop_detached['CONFIGKEY']'" unless args.configkey
      # XXX: CONFIGKEY entry must be in 'config/theman.yml'.
      daemon = EventCollector.new
      # XXX: This will need to be configurable, if we want to run multiple instances.
      #daemon.configkey = args.configkey
      daemon.configkey = 'collector_high'
      daemon.stop('high',true)
    end
  end

  namespace :low do
    desc "Starts the low-priority collector daemon, in order to obtain updated data from the Honeyclient Manager"
    task :start => [:environment] do
      RAILS_DEFAULT_LOGGER.auto_flushing = true
      daemon = EventCollector.new
      daemon.start('low')
    end

    desc "Stops the low-priority collector daemon"
    task :stop => [:environment] do
      RAILS_DEFAULT_LOGGER.auto_flushing = true
      daemon = EventCollector.new
      daemon.stop('low')
    end

    desc "Starts the low-priority collector daemon (detached), in order to obtain updated data from the Honeyclient Manager"
    task :start_detached, :configkey, :needs => [:environment] do |t,args|
      RAILS_DEFAULT_LOGGER.auto_flushing = true
      # XXX: This will need to be configurable, if we want to run multiple instances.
      #abort "Missing config key. Run as 'rake collector:low:start_detached['CONFIGKEY']'" unless args.configkey
      # XXX: CONFIGKEY entry must be in 'config/theman.yml'.
      daemon = EventCollector.new
      # XXX: This will need to be configurable, if we want to run multiple instances.
      #daemon.configkey = args.configkey
      daemon.configkey = 'collector_low'
      daemon.start('low',true)
    end
  
    desc "Stops the low-priority collector daemon (detached)"
    task :stop_detached, :configkey, :needs => [:environment] do |t,args|
      RAILS_DEFAULT_LOGGER.auto_flushing = true
      # XXX: This will need to be configurable, if we want to run multiple instances.
      #abort "Missing config key. Run as 'rake collector:low:stop_detached['CONFIGKEY']'" unless args.configkey
      # XXX: CONFIGKEY entry must be in 'config/theman.yml'.
      daemon = EventCollector.new
      # XXX: This will need to be configurable, if we want to run multiple instances.
      #daemon.configkey = args.configkey
      daemon.configkey = 'collector_low'
      daemon.stop('low',true)
    end
  end
end

