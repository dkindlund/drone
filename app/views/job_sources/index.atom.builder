atom_feed(:schema_date => "2009-06-16") do |feed|
  feed.title(Configuration.find_retry(:name => "atom.title_prefix", :namespace => controller.controller_name.camelize.singularize).to_s + Configuration.find_retry(:name => "atom.title", :namespace => controller.controller_name.camelize.singularize).to_s)
  feed.subtitle(Configuration.find_retry(:name => "atom.description", :namespace => controller.controller_name.camelize.singularize).to_s)

  for job_source in @job_sources
    feed.entry(job_source) do |entry|
      entry.title(job_source.name)
      entry.content :type => 'xhtml' do |xhtml|
        xhtml.p {
          xhtml.text! "Group: #{job_source.group.name}"; xhtml.br
          xhtml.text! "Protocol: #{job_source.protocol}"; xhtml.br
        }
      end
    end
  end
end
