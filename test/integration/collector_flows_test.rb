require 'test_helper'
require 'md5'
require 'sha1'
require 'guid'

class CollectorFlowsTest < ActionController::IntegrationTest
  fixtures :all

  test "should process events properly" do
    collector = EventCollector.new

    # Simulate host creation.
    host = {"host"       =>
             {"ip"       => "10.0.0.3",
              "hostname" => "honeyclient3.foo.com"}}
    result = nil
    assert_nothing_raised do
      result = collector.test_send_event('host.find_or_create', host)
    end
    host_id = result["host"].id

    # Sanity check the output.
    assert         result["host"].valid?, "Host record not valid"
    assert        !result["host"].new_record?, "Host record not saved"
    assert_equal   result["host"].ip, "10.0.0.3", "Invalid host.ip"
    assert_equal   result["host"].hostname, "honeyclient3.foo.com", "Invalid host.hostname"

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
    assert_nothing_raised do
      result = collector.test_send_event('client.find_or_create', client)
    end
    client_id = result["client"].id

    # Sanity check the output.
    assert         result["client"].valid?, "Client record not valid"
    assert        !result["client"].new_record?, "Client record not saved"
    assert_equal   result["client"].quick_clone_name, quick_clone_name, "Invalid client.quick_clone_name"
    assert_equal   result["client"].snapshot_name, snapshot_name, "Invalid client.snapshot_name"
    assert_equal   Time.parse(result["client"].created_at.to_s).to_s, time_at.to_s, "Invalid client.created_at"

    assert_equal   result["client"].host.id, host_id, "Invalid client.host"

    assert         result["client"].os.valid?, "Os record not valid"
    assert        !result["client"].os.new_record?, "Os record not saved"
    assert_equal   result["client"].os.name, "Windows XP Service Pack 2", "Invalid client.os.name"
    assert_equal   result["client"].os.version, "5.1.2600.2", "Invalid client.os.version"
    assert_equal   result["client"].os.short_name, "Microsoft Windows", "Invalid client.os.short_name"

    assert         result["client"].application.valid?, "Application record not valid"
    assert        !result["client"].application.new_record?, "Application record not saved"
    assert_equal   result["client"].application.manufacturer, "Microsoft Corporation", "Invalid client.application.manufacturer"
    assert_equal   result["client"].application.version, "6.0.290.2180", "Invalid client.application.version"
    assert_equal   result["client"].application.short_name, "Internet Explorer", "Invalid client.application.short_name"

    assert         result["client"].client_status.valid?, "ClientStatus record not valid"
    assert        !result["client"].client_status.new_record?, "ClientStatus record not saved"
    assert_equal   result["client"].client_status.status, "created", "Invalid client.client_status.status"

    # Simulate client status change to running.
    client = {"client"             =>
               {"quick_clone_name" => quick_clone_name,
                "snapshot_name"    => snapshot_name,
                "client_status"    =>
                 {"status"         => "running"}}}

    # Specify that we want to update an existing client and specifically
    # just update: client_status sub-hash.
    assert_nothing_raised do
      result = collector.test_send_event('client.find_and_update.client_status', client)
    end

    # Sanity check the output.
    assert_equal   result["client"].id, client_id, "Invalid client"
    assert         result["client"].client_status.valid?, "ClientStatus record not valid"
    assert        !result["client"].client_status.new_record?, "ClientStatus record not saved"
    assert_equal   result["client"].client_status.status, "running", "Invalid client.client_status.status"

    # Simulate a new job getting created.
    job_uuid = Guid.new.to_s
    time_at  = Time.now.utc
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
             "created_at"    => time_at.iso8601.to_s,
             "uuid"          => job_uuid}}

    # Specify that we want to create a new job and don't try
    # to reuse: job, urls, or job_alerts sub-hashes.
    assert_nothing_raised do
      result = collector.test_send_event('job.create.job.urls.job_alerts', job)
    end
    job_id = result["job"].id

    # Sanity check the output.
    assert         result["job"].valid?, "Job record not valid"
    assert        !result["job"].new_record?, "Job record not saved"
    assert_equal   result["job"].uuid, job_uuid, "Invalid job.uuid"
    assert_nil     result["job"].completed_at, "Invalid job.completed_at"
    assert_equal   Time.parse(result["job"].created_at.to_s).to_s, time_at.to_s, "Invalid job.created_at"

    assert         result["job"].job_source.valid?, "JobSource record not valid"
    assert        !result["job"].job_source.new_record?, "JobSource record not saved"
    assert_equal   result["job"].job_source.name, "proxy.foo.com", "Invalid job.job_source.name"
    assert_equal   result["job"].job_source.protocol, "http", "Invalid job.job_source.protocol"

    assert         result["job"].job_alerts.first.valid?, "JobAlert record not valid"
    assert        !result["job"].job_alerts.first.new_record?, "JobAlert record not saved"
    assert_equal   result["job"].job_alerts.first.protocol, "smtp", "Invalid job.job_alerts.first.protocol"
    assert_equal   result["job"].job_alerts.first.address, "admin@foo.com", "Invalid job.job_alerts.first.address"

    assert         result["job"].urls[0].valid?, "Url record not valid"
    assert        !result["job"].urls[0].new_record?, "Url record not saved"
    assert_equal   result["job"].urls[0].url, "http://www.bar.com/", "Invalid job.urls[0].url"
    assert_equal   result["job"].urls[0].priority, 10, "Invalid job.urls[0].priority"
    assert         result["job"].urls[0].url_status.valid?, "UrlStatus record not valid"
    assert        !result["job"].urls[0].url_status.new_record?, "UrlStatus record not saved"
    assert_equal   result["job"].urls[0].url_status.status, "queued", "Invalid job.urls[0].url_status.status"

    assert         result["job"].urls[1].valid?, "Url record not valid"
    assert        !result["job"].urls[1].new_record?, "Url record not saved"
    assert_equal   result["job"].urls[1].url, "http://www.baz.com/", "Invalid job.urls[1].url"
    assert_equal   result["job"].urls[1].priority, 50, "Invalid job.urls[1].priority"
    assert         result["job"].urls[1].url_status.valid?, "UrlStatus record not valid"
    assert        !result["job"].urls[1].url_status.new_record?, "UrlStatus record not saved"
    assert_equal   result["job"].urls[1].url_status.status, "queued", "Invalid job.urls[1].url_status.status"
    
    assert         result["job"].urls[2].valid?, "Url record not valid"
    assert        !result["job"].urls[2].new_record?, "Url record not saved"
    assert_equal   result["job"].urls[2].url, "http://www.foo.com/", "Invalid job.urls[2].url"
    assert_equal   result["job"].urls[2].priority, 100, "Invalid job.urls[2].priority"
    assert         result["job"].urls[2].url_status.valid?, "UrlStatus record not valid"
    assert        !result["job"].urls[2].url_status.new_record?, "UrlStatus record not saved"
    assert_equal   result["job"].urls[2].url_status.status, "queued", "Invalid job.urls[2].url_status.status"
    
    # Reload the object, in order to refresh the *_count references.
    result["job"].reload
    assert_equal   result["job"].url_count, 3, "Invalid job.url_count"

    # Simulate client obtaining a new job.
    job = {"job"                  =>
            {"uuid"               => job_uuid,
             "client"             => 
              {"quick_clone_name" => quick_clone_name,
               "snapshot_name"    => snapshot_name}}}

    # Specify that we want to update an existing job and specifically
    # just update: client sub-hash.
    assert_nothing_raised do
      result = collector.test_send_event('job.find_and_update.client', job)
    end

    # Sanity check the output.
    assert_equal   result["job"].id, job_id, "Invalid job"
    assert_equal   result["job"].client.id, client_id, "Invalid job.client"

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
    assert_nothing_raised do
      result = collector.test_send_event('job.find_and_update.urls.url_status.time_at', job)
    end

    # Sanity check the output.
    assert_equal   result["job"].id, job_id, "Invalid job"
    assert_equal   result["job"].urls[1].url, "http://www.baz.com/", "Invalid job.urls[1].url"
    assert_equal   Time.at(result["job"].urls[1].time_at.to_f).utc.to_s, time_at.to_s, "Invalid job.urls[1].time_at"
    assert         result["job"].urls[1].url_status.valid?, "UrlStatus record not valid"
    assert        !result["job"].urls[1].url_status.new_record?, "UrlStatus record not saved"
    assert_equal   result["job"].urls[1].url_status.status, "timed_out", "Invalid job.urls[1].url_status.status"
    
    assert_equal   result["job"].urls[2].url, "http://www.foo.com/", "Invalid job.urls[2].url"
    assert_equal   Time.at(result["job"].urls[2].time_at.to_f).utc.to_s, time_at.to_s, "Invalid job.urls[2].time_at"
    assert         result["job"].urls[2].url_status.valid?, "UrlStatus record not valid"
    assert        !result["job"].urls[2].url_status.new_record?, "UrlStatus record not saved"
    assert_equal   result["job"].urls[2].url_status.status, "visited", "Invalid job.urls[2].url_status.status"

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
    assert_nothing_raised do
      result = collector.test_send_event('job.find_and_update.completed_at.urls.url_status.time_at', job)
    end

    # Sanity check the output.
    assert_equal   result["job"].id, job_id, "Invalid job"
    assert_equal   Time.parse(result["job"].completed_at.to_s).to_s, time_at.to_s, "Invalid job.created_at"
    assert_equal   result["job"].urls[0].url, "http://www.bar.com/", "Invalid job.urls[0].url"
    assert_equal   Time.at(result["job"].urls[0].time_at.to_f).utc.to_s, time_at.to_s, "Invalid job.urls[0].time_at"
    assert         result["job"].urls[0].url_status.valid?, "UrlStatus record not valid"
    assert        !result["job"].urls[0].url_status.new_record?, "UrlStatus record not saved"
    assert_equal   result["job"].urls[0].url_status.status, "suspicious", "Invalid job.urls[0].url_status.status"

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
    assert_nothing_raised do
      result = collector.test_send_event('fingerprint.create.fingerprint.os_processes.process_files.process_registries', fingerprint)
    end
    fingerprint_id = result["fingerprint"].id

    # Sanity check the output.
    assert         result["fingerprint"].valid?, "Fingerprint record not valid"
    assert        !result["fingerprint"].new_record?, "Fingerprint record not saved"
    assert_equal   result["fingerprint"].checksum, checksum, "Invalid fingerprint.checksum"

    assert         result["fingerprint"].url.valid?, "Url record not valid"
    assert        !result["fingerprint"].url.new_record?, "Url record not saved"
    assert_equal   result["fingerprint"].url.url, "http://www.bar.com/", "Invalid fingerprint.url.url"
    assert_equal   Time.at(result["fingerprint"].url.time_at.to_f).utc.to_s, time_at.to_s, "Invalid fingerprint.url.time_at"

    assert         result["fingerprint"].os_processes[0].valid?, "OsProcess record not valid"
    assert        !result["fingerprint"].os_processes[0].new_record?, "OsProcess record not saved"
    assert_equal   result["fingerprint"].os_processes[0].name, 'C:\Program Files\Internet Explorer\iexplore.exe', "Invalid fingerprint.os_processes[0].name"
    assert_equal   result["fingerprint"].os_processes[0].pid, 9123, "Invalid fingerprint.os_processes[0].pid"

    assert         result["fingerprint"].os_processes[0].process_files[0].valid?, "ProcessFile record not valid"
    assert        !result["fingerprint"].os_processes[0].process_files[0].new_record?, "ProcessFile record not saved"
    assert_equal   result["fingerprint"].os_processes[0].process_files[0].name, 'C:\WINDOWS\fheueyw.exe', "Invalid fingerprint.os_processes[0].process_files[0].name"
    assert_equal   result["fingerprint"].os_processes[0].process_files[0].event, "Write", "Invalid fingerprint.os_processes[0].process_files[0].event"
    assert_equal   Time.at(result["fingerprint"].os_processes[0].process_files[0].time_at.to_f).utc.to_s, time_at.to_s, "Invalid fingerprint.os_processes[0].process_files[0].time_at"
    assert         result["fingerprint"].os_processes[0].process_files[0].file_content.valid?, "FileContent record not valid"
    assert        !result["fingerprint"].os_processes[0].process_files[0].file_content.new_record?, "FileContent record not saved"
    assert_equal   result["fingerprint"].os_processes[0].process_files[0].file_content.md5, MD5.hexdigest(checksum), "Invalid fingerprint.os_processes[0].process_files[0].file_content.md5"
    assert_equal   result["fingerprint"].os_processes[0].process_files[0].file_content.sha1, SHA1.hexdigest(checksum), "Invalid fingerprint.os_processes[0].process_files[0].file_content.sha1"
    assert_equal   result["fingerprint"].os_processes[0].process_files[0].file_content.size, 23847, "Invalid fingerprint.os_processes[0].process_files[0].file_content.size"
    assert_equal   result["fingerprint"].os_processes[0].process_files[0].file_content.mime_type, "application/x-ms-dos-executable", "Invalid fingerprint.os_processes[0].process_files[0].file_content.mime_type"
    assert         result["fingerprint"].os_processes[0].process_files[1].valid?, "ProcessFile record not valid"
    assert        !result["fingerprint"].os_processes[0].process_files[1].new_record?, "ProcessFile record not saved"
    assert_equal   result["fingerprint"].os_processes[0].process_files[1].name, 'C:\WINDOWS\notepad.exe', "Invalid fingerprint.os_processes[0].process_files[1].name"
    assert_equal   result["fingerprint"].os_processes[0].process_files[1].event, "Delete", "Invalid fingerprint.os_processes[0].process_files[1].event"
    assert_equal   Time.at(result["fingerprint"].os_processes[0].process_files[1].time_at.to_f).utc.to_s, time_at.to_s, "Invalid fingerprint.os_processes[0].process_files[1].time_at"

    assert         result["fingerprint"].os_processes[0].process_registries[0].valid?, "ProcessRegistry record not valid"
    assert        !result["fingerprint"].os_processes[0].process_registries[0].new_record?, "ProcessRegistry record not saved"
    assert_equal   result["fingerprint"].os_processes[0].process_registries[0].name, 'HKLM\SYSTEM\ControlSet001\Control\SecurityProviders', "Invalid fingerprint.os_processes[0].process_registries[0].name"
    assert_equal   result["fingerprint"].os_processes[0].process_registries[0].event, "SetValueKey", "Invalid fingerprint.os_processes[0].process_registries[0].event"
    assert_equal   result["fingerprint"].os_processes[0].process_registries[0].value_name, "SecurityProviders", "Invalid fingerprint.os_processes[0].process_registries[0].value_name"
    assert_equal   result["fingerprint"].os_processes[0].process_registries[0].value_type, "REG_SZ", "Invalid fingerprint.os_processes[0].process_registries[0].value_type"
    assert_equal   result["fingerprint"].os_processes[0].process_registries[0].value, "msapsspc.dll, schannel.dll, digest.dll, msnsspc.dll, digeste.dll", "Invalid fingerprint.os_processes[0].process_registries[0].value"
    assert_equal   Time.at(result["fingerprint"].os_processes[0].process_registries[0].time_at.to_f).utc.to_s, time_at.to_s, "Invalid fingerprint.os_processes[0].process_registries[0].time_at"

    assert         result["fingerprint"].os_processes[0].process_registries[1].valid?, "ProcessRegistry record not valid"
    assert        !result["fingerprint"].os_processes[0].process_registries[1].new_record?, "ProcessRegistry record not saved"
    assert_equal   result["fingerprint"].os_processes[0].process_registries[1].name, 'HKLM\SYSTEM\ControlSet002\Control\SecurityProviders', "Invalid fingerprint.os_processes[0].process_registries[1].name"
    assert_equal   result["fingerprint"].os_processes[0].process_registries[1].event, "SetValueKey", "Invalid fingerprint.os_processes[0].process_registries[1].event"
    assert_equal   result["fingerprint"].os_processes[0].process_registries[1].value_name, "SecurityProviders", "Invalid fingerprint.os_processes[0].process_registries[1].value_name"
    assert_equal   result["fingerprint"].os_processes[0].process_registries[1].value_type, "REG_SZ", "Invalid fingerprint.os_processes[0].process_registries[1].value_type"
    assert_equal   result["fingerprint"].os_processes[0].process_registries[1].value, "msapsspc.dll, schannel.dll, digest.dll, msnsspc.dll, digeste.dll", "Invalid fingerprint.os_processes[0].process_registries[1].value"
    assert_equal   Time.at(result["fingerprint"].os_processes[0].process_registries[1].time_at.to_f).utc.to_s, time_at.to_s, "Invalid fingerprint.os_processes[0].process_registries[1].time_at"

    assert         result["fingerprint"].os_processes[1].valid?, "OsProcess record not valid"
    assert        !result["fingerprint"].os_processes[1].new_record?, "OsProcess record not saved"
    assert_equal   result["fingerprint"].os_processes[1].name, 'C:\WINDOWS\fheueyw.exe', "Invalid fingerprint.os_processes[0].name"
    assert_equal   result["fingerprint"].os_processes[1].pid, 7363, "Invalid fingerprint.os_processes[1].pid"

    # Reload the object, in order to refresh the *_count references.
    # XXX: Side effect: os_processes[0] and os_processes[1] are now flipped.
    result["fingerprint"].reload
    assert_equal   result["fingerprint"].os_process_count, 2, "Invalid fingerprint.os_process_count"
    assert_equal   result["fingerprint"].os_processes[1].process_file_count, 2, "Invalid fingerprint.os_processes[0].process_file_count"
    assert_equal   result["fingerprint"].os_processes[1].process_registry_count, 2, "Invalid fingerprint.os_processes[0].process_registry_count"
    assert_equal   result["fingerprint"].os_processes[0].process_file_count, 0, "Invalid fingerprint.os_processes[1].process_file_count"
    assert_equal   result["fingerprint"].os_processes[0].process_registry_count, 0, "Invalid fingerprint.os_processes[1].process_registry_count"

    # Simulate client status change to suspicious.
    client = {"client"             =>
               {"quick_clone_name" => quick_clone_name,
                "snapshot_name"    => snapshot_name,
                "suspended_at"     => time_at.iso8601.to_s,
                "client_status"    =>
                  {"status"        => "suspicious"}}}

    # Specify that we want to update an existing client and specifically
    # just update: client_status and suspended_at sub-hashes.
    assert_nothing_raised do
      result = collector.test_send_event('client.find_and_update.client_status.suspended_at', client)
    end

    # Sanity check the output.
    assert_equal   result["client"].id, client_id, "Invalid client"
    assert         result["client"].client_status.valid?, "ClientStatus record not valid"
    assert        !result["client"].client_status.new_record?, "ClientStatus record not saved"
    assert_equal   result["client"].client_status.status, "suspicious", "Invalid client.client_status.status"
    assert_equal   Time.parse(result["client"].suspended_at.to_s).to_s, time_at.to_s, "Invalid client.suspended_at"

  end
end
