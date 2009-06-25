atom_feed(:schema_date => "2009-06-16") do |feed|
  feed.title(h(Configuration.find_retry(:name => "atom.title_prefix", :namespace => controller.controller_name.camelize.singularize).to_s) + h(Configuration.find_retry(:name => "atom.title", :namespace => controller.controller_name.camelize.singularize).to_s))
  feed.subtitle(h(Configuration.find_retry(:name => "atom.description", :namespace => controller.controller_name.camelize.singularize).to_s))

  for os in @oses
    feed.entry(os, :url => 'os') do |entry|
      entry.title(h(os.name.to_s) + " - " + h(os.version.to_s))
      entry.content :type => 'xhtml' do |xhtml|
        xhtml.p {
          xhtml.text! "Name: #{h(os.name)}"; xhtml.br
          xhtml.text! "Short Name: #{h(os.short_name)}"; xhtml.br
          xhtml.text! "Version: #{h(os.version)}"; xhtml.br
        }
      end
    end
  end
end
