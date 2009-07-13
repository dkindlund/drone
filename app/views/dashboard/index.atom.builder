require 'uri'

atom_feed(:schema_date => "2009-06-16") do |feed|
  feed.title(h(Configuration.find_retry(:name => "atom.title_prefix", :namespace => controller.controller_name.camelize.singularize).to_s) + h(Configuration.find_retry(:name => "atom.title", :namespace => controller.controller_name.camelize.singularize).to_s))

  feed.subtitle(h(Configuration.find_retry(:name => "atom.description", :namespace => controller.controller_name.camelize.singularize).to_s))
  pcap_directory = Configuration.find_retry(:name => "pcap.directory", :namespace => "Fingerprint").to_s

  first_entry = true
  while ((@suspicious_urls.size > 0) || (@compromised_urls.size > 0))
    # Figure out which URL entry is more recent.
    url = @suspicious_urls.shift 
    if (url.nil? ||
        (!@compromised_urls.first.nil? &&
         (@compromised_urls.first.time_at > url.time_at)))
      if !url.nil?
        @suspicious_urls.unshift(url)
      end
      url = @compromised_urls.shift
    end
    if first_entry
      feed.updated(Time.at(url.time_at.to_f))
    end

    feed.entry(url) do |entry|
      entry.title(h(url.url.to_s))
      entry.updated(Time.at(url.time_at.to_f).strftime("%Y-%m-%dT%H:%M:%SZ"))
      entry.content :type => 'xhtml' do |xhtml|
        xhtml.p {
          if (!url.url_status.nil? && !url.url_status.status.nil?)
            xhtml.text! "Status: "; xhtml.b(h(url.url_status.status)); xhtml.br
          end
          if (!url.ip.nil?)
            xhtml.text! "IP: #{h(url.ip)}"; xhtml.br
          end
          if (!url.job_source.nil?)
            xhtml.text! "Source: #{h(url.job_source)}"; xhtml.br
          end
          if !url.fingerprint.nil?
            fingerprint_url = url_for({:controller => "fingerprints", :action => "show", :id => url.fingerprint.id})
            xhtml.text! "Checksum: "; xhtml.a(h(url.fingerprint.checksum), "href" => SITE_URL + fingerprint_url); xhtml.br
            if (!url.fingerprint.pcap.nil?)
              pcap_url = url_for({:controller => "fingerprints", :action => "download_pcap", :id => url.fingerprint.id})
              xhtml.text! "PCAP: "; xhtml.a(SITE_URL + h(pcap_url), "href" => SITE_URL + pcap_url); xhtml.br
            end
            xhtml.text! "# Processes: #{h(url.fingerprint.os_process_count)}"; xhtml.br
          end
        }
        if (!url.fingerprint.nil? && (url.fingerprint.os_processes.size > 0))
          url.fingerprint.os_processes.each do |os_process|
            xhtml.p {
              xhtml.text! "Process Name: #{h(os_process.name)}"; xhtml.br
              xhtml.text! "PID: #{h(os_process.pid)}"; xhtml.br
              if (!os_process.parent_name.nil?)
                xhtml.text! "Parent Name: #{h(os_process.parent_name)}"; xhtml.br
                xhtml.text! "Parent PID: #{h(os_process.parent_pid)}"; xhtml.br
              end
              if (os_process.process_file_count > 0)
                xhtml.text! "# Files: #{h(os_process.process_file_count)}"; xhtml.br
              end
              if (os_process.process_registry_count > 0)
                xhtml.text! "# Registries: #{h(os_process.process_registry_count)}"; xhtml.br
              end

              if (os_process.process_files.size > 0)
                xhtml.ul {
                  os_process.process_files.each do |process_file|
                    if (!process_file.file_content.nil? && process_file.file_content.mime_type != 'UNKNOWN')
                      xhtml.li {
                        xhtml.text! "At: #{Time.at(process_file.time_at.to_f).strftime("%Y-%m-%dT%H:%M:%SZ")}"; xhtml.br
                        xhtml.text! "Event: #{h(process_file.event)}"; xhtml.br
                        xhtml.text! "Filename: #{h(process_file.name)}"; xhtml.br
                        xhtml.text! "MD5: #{h(process_file.file_content.md5)}"; xhtml.br
                        xhtml.text! "SHA1: #{h(process_file.file_content.sha1)}"; xhtml.br
                        xhtml.text! "Size: #{h(process_file.file_content.size)}"; xhtml.br
                        xhtml.text! "Type: #{h(process_file.file_content.mime_type)}"; xhtml.br
                      }
                    end
                  end
                }
              end
              if (os_process.process_registries.size > 0)
                xhtml.ul {
                  os_process.process_registries.each do |process_registry|
                    xhtml.li {
                      xhtml.text! "At: #{Time.at(process_registry.time_at.to_f).strftime("%Y-%m-%dT%H:%M:%SZ")}"; xhtml.br
                      xhtml.text! "Event: #{h(process_registry.event)}"; xhtml.br
                      xhtml.text! "Value Name: #{h(process_registry.value_name)}"; xhtml.br
                      xhtml.text! "Value Type: #{h(process_registry.value_type)}"; xhtml.br
                      xhtml.text! "Value: #{h(process_registry.value)}"; xhtml.br
                    }
                  end
                }
              end
            }
          end
          related_urls_pivot_fields = [ 'urls.ip = ? OR urls.url LIKE ?', url.ip, "%" + URI.parse(url.url).host().to_s + "%" ]
          joins = ''
          if !url.fingerprint.checksum.nil?
            joins = 'LEFT JOIN fingerprints ON urls.fingerprint_id = fingerprints.id'
            related_urls_pivot_fields = [ 'urls.ip = ? OR urls.url LIKE ? OR fingerprints.checksum = ?', url.ip, "%" + URI.parse(url.url).host().to_s + "%", url.fingerprint.checksum.to_s ]
          end
          related_urls = Url.find(:all, :from => 'urls', :joins => joins, :conditions => Url.merge_conditions(related_urls_pivot_fields, [ 'urls.id != ? AND fingerprint_id IS NOT NULL AND urls.url_status_id IN (?,?,?)', url.id, UrlStatus.find_by_status("suspicious").id, UrlStatus.find_by_status("compromised"), UrlStatus.find_by_status("timed_out") ]), :limit => Configuration.find_retry(:name => "atom.max_entries", :namespace => "Dashboard").to_i)
          if related_urls.size > 0
            xhtml.p {
              xhtml.text! "Possible Related Threats:"; xhtml.br
              xhtml.ul {
                related_urls.each do |related_url|
                  xhtml.li {
                    related_fingerprint_url = url_for({:controller => "fingerprints", :action => "show", :id => related_url.fingerprint.id})
                    xhtml.a(h(related_url.url), "href" => SITE_URL + related_fingerprint_url); xhtml.br
                  }
                end
              }
            }
          end
        end
      end
    end
  end
end
