atom_feed(:schema_date => "2009-06-16") do |feed|
  feed.title(Configuration.find_retry(:name => "atom.title_prefix", :namespace => controller.controller_name.camelize.singularize).to_s + Configuration.find_retry(:name => "atom.title", :namespace => controller.controller_name.camelize.singularize).to_s)
  feed.updated(Time.at(@data.first[1].time_at.to_f))
  feed.subtitle(Configuration.find_retry(:name => "atom.description", :namespace => controller.controller_name.camelize.singularize).to_s)

  for element in @data
    file_content = element[0]
    url          = element[1]
    feed.entry(file_content) do |entry|
      entry.title("MD5: " + file_content.md5.to_s)
      entry.updated(Time.at(url.time_at.to_f).strftime("%Y-%m-%dT%H:%M:%SZ"))
      entry.content :type => 'xhtml' do |xhtml|
        xhtml.p {
          if (!url.url.nil?)
            xhtml.text! "URL: #{url.url}"; xhtml.br
          end
          if (!url.url_status.nil? && !url.url_status.status.nil?)
            xhtml.text! "Status: "; xhtml.b(url.url_status.status); xhtml.br
          end
          xhtml.text! "MD5: #{file_content.md5}"; xhtml.br
          xhtml.text! "SHA1: #{file_content.sha1}"; xhtml.br
          xhtml.text! "Size: #{file_content.size}"; xhtml.br
          xhtml.text! "Type: #{file_content.mime_type}"; xhtml.br
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
                xhtml.li name
              end
            }
          end
        }
      end
    end
  end
end
