atom_feed(:schema_date => "2009-06-16") do |feed|
  feed.title(Configuration.find_retry(:name => "atom.title_prefix", :namespace => controller.controller_name.camelize.singularize).to_s + Configuration.find_retry(:name => "atom.title", :namespace => controller.controller_name.camelize.singularize).to_s)
  feed.subtitle(Configuration.find_retry(:name => "atom.description", :namespace => controller.controller_name.camelize.singularize).to_s)

  for configuration in @configurations
    feed.entry(configuration) do |entry|
      entry.title(((configuration.namespace.nil? || configuration.namespace.empty?) ? "global" : configuration.namespace) + " - " + configuration.name)
      entry.content :type => 'xhtml' do |xhtml|
        xhtml.p {
          xhtml.text! "Namespace: #{configuration.namespace}"; xhtml.br
          xhtml.text! "Name: #{configuration.name}"; xhtml.br
          xhtml.text! "Value: #{configuration.value}"; xhtml.br
          xhtml.text! "Description: #{configuration.description}"; xhtml.br
        }
      end
    end
  end
end
