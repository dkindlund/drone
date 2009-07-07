atom_feed(:schema_date => "2009-06-16") do |feed|
  feed.title(h(Configuration.find_retry(:name => "atom.title_prefix", :namespace => controller.controller_name.camelize.singularize).to_s) + h(Configuration.find_retry(:name => "atom.title", :namespace => controller.controller_name.camelize.singularize).to_s))
  feed.subtitle(h(Configuration.find_retry(:name => "atom.description", :namespace => controller.controller_name.camelize.singularize).to_s))

  for job_source in @job_sources
    feed.entry(job_source) do |entry|
      entry.title(h(job_source.name))
      entry.content :type => 'xhtml' do |xhtml|
        xhtml.p {
          if !job_source.group.nil?
            xhtml.text! "Group: #{h(job_source.group.name)}"; xhtml.br
          end
          xhtml.text! "Protocol: #{h(job_source.protocol)}"; xhtml.br
        }
      end
    end
  end
end
