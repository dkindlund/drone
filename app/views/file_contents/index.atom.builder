atom_feed(:schema_date => "2009-06-16") do |feed|
  feed.title(h(Configuration.find_retry(:name => "atom.title_prefix", :namespace => controller.controller_name.camelize.singularize).to_s) + h(Configuration.find_retry(:name => "atom.title", :namespace => controller.controller_name.camelize.singularize).to_s))
  if (!@data.first.nil? && !@data.first[1].nil?)
    feed.updated(Time.at(@data.first[1].time_at.to_f))
  end
  feed.subtitle(h(Configuration.find_retry(:name => "atom.description", :namespace => controller.controller_name.camelize.singularize).to_s))

  for element in @data
    file_content = element[0]
    url          = element[1]
    feed.entry(file_content) do |entry|
      entry.title("MD5: " + h(file_content.md5.to_s))
      entry.updated(Time.at(url.time_at.to_f).strftime("%Y-%m-%dT%H:%M:%SZ"))
      entry.content :type => 'xhtml' do |xhtml|
        xhtml.p {
          if (!url.url.nil?)
            xhtml.text! "URL: #{h(url.url)}"; xhtml.br
          end
          if (!url.url_status.nil? && !url.url_status.status.nil?)
            xhtml.text! "Status: "; xhtml.b(h(url.url_status.status)); xhtml.br
          end
          xhtml.text! "MD5: #{h(file_content.md5)}"; xhtml.br
          xhtml.text! "SHA1: #{h(file_content.sha1)}"; xhtml.br
          xhtml.text! "Size: #{h(file_content.size)}"; xhtml.br
          xhtml.text! "Type: #{h(file_content.mime_type)}"; xhtml.br
          if (file_content.process_files.size > 0)
            names = []
            file_content.process_files.each do |process_file|
              if (!process_file.name.nil?)
                names << process_file.name
              end
            end
            names.uniq!

            xhtml.text! "Names:"; xhtml.br
            xhtml.ul {
              names.each do |name|
                xhtml.li h(name)
              end
            }
          end
        }
      end
    end
  end
end
