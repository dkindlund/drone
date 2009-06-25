atom_feed(:schema_date => "2009-06-16") do |feed|
  feed.title(h(Configuration.find_retry(:name => "atom.title_prefix", :namespace => controller.controller_name.camelize.singularize).to_s) + h(Configuration.find_retry(:name => "atom.title", :namespace => controller.controller_name.camelize.singularize).to_s))
  feed.subtitle(h(Configuration.find_retry(:name => "atom.description", :namespace => controller.controller_name.camelize.singularize).to_s))

  for application in @applications
    feed.entry(application, :url => 'applications') do |entry|
      entry.title(h(application.manufacturer.to_s) + " - " + h(application.short_name.to_s) + " v" + h(application.version.to_s))
      entry.content :type => 'xhtml' do |xhtml|
        xhtml.p {
          xhtml.text! "Manufacturer: #{h(application.manufacturer)}"; xhtml.br
          xhtml.text! "Short Name: #{h(application.short_name)}"; xhtml.br
          xhtml.text! "Version: #{h(application.version)}"; xhtml.br
        }
      end
    end
  end
end
