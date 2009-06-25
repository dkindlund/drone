atom_feed(:schema_date => "2009-06-16") do |feed|
  feed.title(h(Configuration.find_retry(:name => "atom.title_prefix", :namespace => controller.controller_name.camelize.singularize).to_s) + h(Configuration.find_retry(:name => "atom.title", :namespace => controller.controller_name.camelize.singularize).to_s))
  if (!@data.first.nil? && !@data.first[1].nil?)
    feed.updated(Time.at(@data.first[1].time_at.to_f))
  end
  feed.subtitle(h(Configuration.find_retry(:name => "atom.description", :namespace => controller.controller_name.camelize.singularize).to_s))

  for element in @data
    os_process = element[0]
    url        = element[1]
    feed.entry(os_process) do |entry|
      entry.title(h(os_process.name.to_s))
      entry.updated(Time.at(url.time_at.to_f).strftime("%Y-%m-%dT%H:%M:%SZ"))
      entry.content :type => 'xhtml' do |xhtml|
        xhtml.p {
          if (!url.url.nil?)
            xhtml.text! "URL: #{h(url.url)}"; xhtml.br
          end
          if (!url.url_status.nil? && !url.url_status.status.nil?)
            xhtml.text! "Status: "; xhtml.b(h(url.url_status.status)); xhtml.br
          end
          xhtml.text! "PID: #{h(os_process.pid)}"; xhtml.br
          xhtml.text! "Parent Name: #{h(os_process.parent_name)}"; xhtml.br
          xhtml.text! "Parent PID: #{h(os_process.parent_pid)}"; xhtml.br
          xhtml.text! "# Files: #{h(os_process.process_file_count)}"; xhtml.br
          xhtml.text! "# Registries: #{h(os_process.process_registry_count)}"; xhtml.br
        }
      end
    end
  end
end
