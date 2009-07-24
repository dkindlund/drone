atom_feed(:schema_date => "2009-06-16") do |feed|
  feed.title(h(Configuration.find_retry(:name => "atom.title_prefix", :namespace => controller.controller_name.camelize.singularize).to_s) + h(Configuration.find_retry(:name => "atom.title", :namespace => controller.controller_name.camelize.singularize).to_s))
  if (!@data.first.nil? && !@data.first[0].nil?)
    feed.updated(Time.at(@data.first[0].time_at.to_f))
  end
  feed.subtitle(h(Configuration.find_retry(:name => "atom.description", :namespace => controller.controller_name.camelize.singularize).to_s))
  pcap_directory = Configuration.find_retry(:name => "pcap.directory", :namespace => "Fingerprint").to_s

  for element in @data
    url         = element[0]
    fingerprint = element[1]
    feed.entry(fingerprint) do |entry|
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
          if (!fingerprint.pcap.nil?)
            pcap_url = url_for({:controller => "fingerprints", :action => "download_pcap", :id => fingerprint.id})
            xhtml.text! "PCAP: "; xhtml.a(SITE_URL + h(pcap_url), "href" => SITE_URL + pcap_url); xhtml.br
          end
          xhtml.text! "Checksum: #{h(fingerprint.checksum)}"; xhtml.br
          xhtml.text! "# Processes: #{h(fingerprint.os_process_count)}"; xhtml.br
        }
        if (fingerprint.os_processes.size > 0)
          fingerprint.os_processes.each do |os_process|
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

                        if (!process_file.file_content.data.nil?)
                          # We need to figure out which groups are allowed to download this file content.
                          # Unfortunately, this requires iterating through any referenced URLs and collecting
                          # all applicable group_ids.
                          group_ids = []
                          # Clear the cache, if need be.
                          url.expire_caches
                          group_ids << url.group_id
                          group_ids.uniq!

                          if (!group_ids.index(nil).nil? ||
                              current_user.has_role?(:admin) ||
                              ((current_user.groups.map{|g| g.is_a?(Group) ? g.id : g} & group_ids).size > 0))
                            data_url = url_for({:controller => "file_contents", :action => "download_data", :id => process_file.file_content.id})
                            xhtml.text! "Data: "; xhtml.a(SITE_URL + h(data_url), "href" => SITE_URL + data_url); xhtml.br
                            xhtml.text! "Password: #{h(Configuration.find_retry(:name => "file_content.zip.password", :namespace => "FileContent").to_s)}"; xhtml.br
                          end
                        end
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
        end
      end
    end
  end
end
