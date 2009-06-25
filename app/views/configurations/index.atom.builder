atom_feed(:schema_date => "2009-06-16") do |feed|
  feed.title(h(Configuration.find_retry(:name => "atom.title_prefix", :namespace => controller.controller_name.camelize.singularize).to_s) + h(Configuration.find_retry(:name => "atom.title", :namespace => controller.controller_name.camelize.singularize).to_s))
  feed.subtitle(h(Configuration.find_retry(:name => "atom.description", :namespace => controller.controller_name.camelize.singularize).to_s))

  for configuration in @configurations
    feed.entry(configuration) do |entry|
      entry.title(((configuration.namespace.nil? || configuration.namespace.empty?) ? "global" : h(configuration.namespace)) + " - " + h(configuration.name))
      entry.content :type => 'xhtml' do |xhtml|
        xhtml.p {
          xhtml.text! "Namespace: #{h(configuration.namespace)}"; xhtml.br
          xhtml.text! "Name: #{h(configuration.name)}"; xhtml.br
          xhtml.text! "Value: #{h(configuration.value)}"; xhtml.br
          xhtml.text! "Description: #{h(configuration.description)}"; xhtml.br
        }
      end
    end
  end
end
