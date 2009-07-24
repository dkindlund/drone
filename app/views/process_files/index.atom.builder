atom_feed(:schema_date => "2009-06-16") do |feed|
  feed.title(h(Configuration.find_retry(:name => "atom.title_prefix", :namespace => controller.controller_name.camelize.singularize).to_s) + h(Configuration.find_retry(:name => "atom.title", :namespace => controller.controller_name.camelize.singularize).to_s))
  if (!@data.first.nil? && !@data.first[1].nil?)
    feed.updated(Time.at(@data.first[1].time_at.to_f))
  end
  feed.subtitle(h(Configuration.find_retry(:name => "atom.description", :namespace => controller.controller_name.camelize.singularize).to_s))

  for element in @data
    process_file = element[0]
    url          = element[1]
    feed.entry(process_file) do |entry|
      entry.title(h(process_file.name.to_s))
      entry.updated(Time.at(process_file.time_at.to_f).strftime("%Y-%m-%dT%H:%M:%SZ"))
      entry.content :type => 'xhtml' do |xhtml|
        xhtml.p {
          if (!url.url.nil?)
            xhtml.text! "URL: #{h(url.url)}"; xhtml.br
          end
          if (!url.url_status.nil? && !url.url_status.status.nil?)
            xhtml.text! "Status: "; xhtml.b(h(url.url_status.status)); xhtml.br
          end
          if (!process_file.os_process.nil?)
            xhtml.text! "Process Name: #{h(process_file.os_process.name)}"; xhtml.br
          end
          xhtml.text! "Event: #{h(process_file.event)}"; xhtml.br
          if (!process_file.file_content.nil?)
            xhtml.text! "MD5: #{h(process_file.file_content.md5)}"; xhtml.br
            xhtml.text! "SHA1: #{h(process_file.file_content.sha1)}"; xhtml.br
            xhtml.text! "Size: #{h(process_file.file_content.size)}"; xhtml.br
            xhtml.text! "Type: #{h(process_file.file_content.mime_type)}"; xhtml.br

            if (!process_file.file_content.data.nil?)
              # We need to figure out which groups are allowed to download this file content.
              # Unfortunately, this requires iterating through any referenced URLs and collecting
              # all applicable group_ids.
              group_ids = []
              if (!process_file.os_process.nil? &&
                  !process_file.os_process.fingerprint.nil? &&
                  !process_file.os_process.fingerprint.url.nil?)
                # Clear the cache, if need be.
                process_file.os_process.fingerprint.url.expire_caches
                group_ids << process_file.os_process.fingerprint.url.group_id
              end
              group_ids.uniq!
  
              if (!group_ids.index(nil).nil? ||
                  current_user.has_role?(:admin) ||
                  ((current_user.groups.map{|g| g.is_a?(Group) ? g.id : g} & group_ids).size > 0))
                data_url = url_for({:controller => "file_contents", :action => "download_data", :id => process_file.file_content.id})
                xhtml.text! "Data: "; xhtml.a(SITE_URL + h(data_url), "href" => SITE_URL + data_url); xhtml.br
                xhtml.text! "Password: #{h(Configuration.find_retry(:name => "file_content.zip.password", :namespace => "FileContent").to_s)}"; xhtml.br
              end
            end
          end
        }
      end
    end
  end
end
