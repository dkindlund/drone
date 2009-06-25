atom_feed(:schema_date => "2009-06-16") do |feed|
  feed.title(h(Configuration.find_retry(:name => "atom.title_prefix", :namespace => controller.controller_name.camelize.singularize).to_s) + h(Configuration.find_retry(:name => "atom.title", :namespace => controller.controller_name.camelize.singularize).to_s))
  if (!@data.first.nil? && !@data.first[1].nil?)
    feed.updated(Time.at(@data.first[1].time_at.to_f))
  end
  feed.subtitle(h(Configuration.find_retry(:name => "atom.description", :namespace => controller.controller_name.camelize.singularize).to_s))
  pcap_directory = Configuration.find_retry(:name => "pcap.directory", :namespace => "Fingerprint").to_s

  for element in @data
    job         = element[0]
    url         = element[1]
    feed.entry(job) do |entry|
      entry.title(h(job.uuid.to_s))
      entry.updated(Time.at(url.time_at.to_f).strftime("%Y-%m-%dT%H:%M:%SZ"))
      entry.content :type => 'xhtml' do |xhtml|
        xhtml.p {
          if (!url.url.nil?)
            xhtml.text! "URL: #{h(url.url)}"; xhtml.br
          end
          if (!url.url_status.nil? && !url.url_status.status.nil?)
            xhtml.text! "Status: "; xhtml.b(h(url.url_status.status)); xhtml.br
          end
          if (!job.job_source.nil?)
            xhtml.text! "Source Name: #{h(job.job_source.name)}"; xhtml.br
            xhtml.text! "Source Protocol: #{h(job.job_source.protocol)}"; xhtml.br
          end
        }
      end
    end
  end
end
