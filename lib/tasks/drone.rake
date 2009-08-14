# Drone Tasks
#
# Used for maintaining the Drone database.

namespace :drone do
  desc "Flushes all queued URLs older than 5 minutes"
  task :flush_queued_urls => [:environment] do
    RAILS_DEFAULT_LOGGER.auto_flushing = true
    # Find all matching URLs.
    urls = Url.find(:all, :conditions => [ "url_status_id = :url_status_queued AND updated_at < :updated_at_lt", {:url_status_queued => UrlStatus.find_by_status("queued").id.to_s, :updated_at_lt => 5.minutes.ago}])

    # Update all matching URLs.
    Url.update_all("url_status_id = " + UrlStatus.find_by_status("ignored").id.to_s, [ "url_status_id = :url_status_queued AND updated_at < :updated_at_lt", {:url_status_queued => UrlStatus.find_by_status("queued").id.to_s, :updated_at_lt => 5.minutes.ago}])

    # Expire the corresponding caches.
    urls.each do |url|
      url.expire_caches
    end
  end

  desc "Removes PCAP data corresponding to URLs that are neither suspicious nor compromised"
  task :cleanup_pcaps => [:environment] do
    RAILS_DEFAULT_LOGGER.auto_flushing = true

    compromised_status = UrlStatus.find_by_status("compromised")
    suspicious_status = UrlStatus.find_by_status("suspicious")
    fingerprints = Fingerprint.find(:all, :conditions => ['fingerprints.pcap IS NOT NULL'])

    fingerprints.each do |fingerprint|
      if (!fingerprint.url.nil? &&
          (fingerprint.url.url_status != compromised_status) &&
          (fingerprint.url.url_status != suspicious_status))

        # Delete the PCAP file.
        File.unlink(fingerprint.pcap.to_s)

        # Remove the PCAP reference.
        fingerprint.pcap = nil
        fingerprint.save!
        fingerprint.expire_caches
      end
    end
  end
  
  desc "Removes FileContent data corresponding to URLs that are neither suspicious nor compromised"
  task :cleanup_files => [:environment] do
    RAILS_DEFAULT_LOGGER.auto_flushing = true

    compromised_status = UrlStatus.find_by_status("compromised")
    suspicious_status = UrlStatus.find_by_status("suspicious")
    file_contents = FileContent.find(:all, :conditions => ['file_contents.data IS NOT NULL'])

    file_contents.each do |file_content|
      delete_data = true 
      file_content.process_files.each do |process_file|
        if (!process_file.os_process.fingerprint.nil? &&
            !process_file.os_process.fingerprint.url.nil? &&
            ((process_file.os_process.fingerprint.url.url_status == compromised_status) ||
             (process_file.os_process.fingerprint.url.url_status == suspicious_status)))
          delete_data = false
          break 
        end
      end

      if delete_data
        # Delete the file.
        File.unlink(file_content.data.to_s)
  
        # Remove the file reference.
        file_content.data = nil
        file_content.save!
        file_content.expire_caches
      end
    end
  end

  desc "Marks all suspended VMs as error, so that they can be cleaned up by the Manager"
  task :cleanup_clients => [:environment] do
    RAILS_DEFAULT_LOGGER.auto_flushing = true

    client_status_id_suspended = ClientStatus.find_by_status("suspended").id
    client_status_id_error     = ClientStatus.find_by_status("error").id

    # Find all matching Clients.
    clients = Client.find_all_by_client_status_id(client_status_id_suspended)

    # Update all matching Clients.
    Client.update_all("client_status_id = " + client_status_id_error.to_s, [ "client_status_id = :client_status_id_suspended", {:client_status_id_suspended => client_status_id_suspended.to_s}])

    # Expire the corresponding caches.
    clients.each do |client|
      client.expire_caches
    end
  end

  desc "Updates all clients' status and their corresponding URLs, based upon the arguments FROM=client_status and TO=client_status"
  task :update_clients_status => [:environment] do
    RAILS_DEFAULT_LOGGER.auto_flushing = true

    raise "FROM is required" unless ENV["FROM"]
    raise "TO is required" unless ENV["TO"]

    client_status_id_from = ClientStatus.find_by_status(ENV["FROM"])
    client_status_id_to = ClientStatus.find_by_status(ENV["TO"])

    if (client_status_id_from.nil?)
      raise "FROM=" + ENV["FROM"] + " is not a valid status type"
    else
      client_status_id_from = client_status_id_from.id
    end

    if (client_status_id_to.nil?)
      raise "TO=" + ENV["TO"] + " is not a valid status type"
    else
      client_status_id_to = client_status_id_to.id
    end

    # Find all matching Clients.
    clients = Client.find_all_by_client_status_id(client_status_id_from)

    # Update all matching Clients.
    Client.update_all("client_status_id = " + client_status_id_to.to_s, [ "client_status_id = :client_status_id_from", {:client_status_id_from => client_status_id_from.to_s}])

    last_url_status = nil
    if ENV["TO"] == "suspicious"
      last_url_status = UrlStatus.find_by_status("suspicious")
    elsif ENV["TO"] == "compromised"
      last_url_status = UrlStatus.find_by_status("compromised")
    elsif ENV["TO"] == "deleted"
      last_url_status = UrlStatus.find_by_status("ignored")
    elsif ENV["TO"] == "false_positive"
      last_url_status = UrlStatus.find_by_status("visited")
    elsif ENV["TO"] == "error"
      last_url_status = UrlStatus.find_by_status("error")
    end

    if !last_url_status.nil?
      clients.each do |client|
        client.reload
        # When we update the client status field, make sure last URL entry is also updated (if needed).
        last_url = Url.find(:first, :conditions => ["urls.client_id = ?", client.id], :order => "urls.time_at DESC")
        if !last_url.nil?
          last_url.url_status = last_url_status
          last_url.save!
          last_url.expire_caches
        end
        client.expire_caches
      end
    else
      clients.each do |client|
        # Expire the corresponding caches.
        client.expire_caches
      end
    end
  end

  desc "Updates URL statistics"
  task :update_url_stats => [:environment] do
    RAILS_DEFAULT_LOGGER.auto_flushing = true

    RAILS_DEFAULT_LOGGER.info "Updating URL statistics."
    puts "Updating URL statistics."

    # Disable automatic timestamps.
    UrlStatistic.record_timestamps = false

    # Hash of URL status types to process.
    url_status_types = {
      :visited     => {:id => UrlStatus.find_by_status("visited").id, :field => :time_at},
      :suspicious  => {:id => UrlStatus.find_by_status("suspicious").id, :field => :time_at},
      :compromised => {:id => UrlStatus.find_by_status("compromised").id, :field => :time_at},
      :timed_out   => {:id => UrlStatus.find_by_status("timed_out").id, :field => :updated_at},
      :error       => {:id => UrlStatus.find_by_status("error").id, :field => :updated_at},
      :ignored     => {:id => UrlStatus.find_by_status("ignored").id, :field => :updated_at},
    } 

    last_updated_at = nil
    sample_interval = Configuration.find_retry(:name => "sample.interval", :namespace => "UrlStatistic").to_s

    # Find the most recent UrlStatistic entry.
    most_recent_entry = UrlStatistic.find(:first, :conditions => ["updated_at IS NOT NULL"], :order => "updated_at DESC")
    if (most_recent_entry.nil?)
      # If there are no UrlStatistic entries, then search for the oldest Url entry.
      oldest_entry = Url.find(:first, :conditions => ["time_at IS NOT NULL"], :order => "time_at ASC")

      # If there are no Url entries, then stop processing.
      if (oldest_entry.nil?)
        RAILS_DEFAULT_LOGGER.info "No URLs found."
        puts "No URLs found."
        exit
      end

      # If we found the oldest entry, then pull out the start time.
      last_updated_at = Time.at(oldest_entry.time_at.to_f)
    else
      last_updated_at = most_recent_entry.updated_at
    end

    RAILS_DEFAULT_LOGGER.info "Last updated at: " + last_updated_at.to_s
    puts "Last Updated At: " + last_updated_at.to_s

    # Find out if we need to generate updates.
    sample_interval_ago = eval(sample_interval + ".ago")
    if (last_updated_at > sample_interval_ago)
      RAILS_DEFAULT_LOGGER.info "URL statistics already up-to-date."
      puts "URL statistics already up-to-date."
      exit
    end

    RAILS_DEFAULT_LOGGER.info "Collecting URL statistics."
    puts "Collecting URL statistics."

    sample_interval = eval(sample_interval)
    start_time = last_updated_at
    end_time   = start_time + sample_interval
    while (end_time < Time.now)

      # Iterate through all URL status types.
      UrlStatistic.transaction do
        url_status_types.each do |type,data|
          count = Url.count(:conditions => ["url_status_id = :url_status_id AND " + data[:field].to_s + " >= :start_time AND " + data[:field].to_s + " < :end_time",
                                            {:url_status_id => data[:id],
                                             :start_time    => ((data[:field] == :time_at) ? start_time.to_f.to_s : start_time),
                                             :end_time      => ((data[:field] == :time_at) ? end_time.to_f.to_s : end_time)}]) 
          if (count > 0)
            RAILS_DEFAULT_LOGGER.info "[" + start_time.to_s + "] - [" + end_time.to_s + "] # " + type.to_s + ": " + count.to_s
            puts "[" + start_time.to_s + "] - [" + end_time.to_s + "] # " + type.to_s + ": " + count.to_s
          end
          UrlStatistic.new(:url_status_id => data[:id], :count => count, :created_at => start_time, :updated_at => end_time).save!
        end
      end

      start_time = end_time
      end_time = start_time + sample_interval
    end
  end
end

namespace :tmp do
  namespace :attachment_fu do
    desc "Clears all files in tmp/attachment_fu that are older than 5 minutes"
    task :clear => [:environment] do
      RAILS_DEFAULT_LOGGER.auto_flushing = true
      tempfile_path = File.join(RAILS_ROOT, 'tmp', 'attachment_fu', '*')
      Dir.glob(tempfile_path) do |file|
        if (File.atime(file) < 5.minutes.ago)
          RAILS_DEFAULT_LOGGER.info "Deleting file " + file.to_s
          puts "Deleting file " + file.to_s
          begin
            File.delete(file)
          rescue
          end
        end
      end
    end
  end
end
