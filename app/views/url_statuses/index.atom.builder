atom_feed(:schema_date => "2009-06-16") do |feed|
  feed.title(h(Configuration.find_retry(:name => "atom.title_prefix", :namespace => controller.controller_name.camelize.singularize).to_s) + h(Configuration.find_retry(:name => "atom.title", :namespace => controller.controller_name.camelize.singularize).to_s))
  feed.subtitle(h(Configuration.find_retry(:name => "atom.description", :namespace => controller.controller_name.camelize.singularize).to_s))

  for url_status in @url_statuses
    feed.entry(url_status, :url => 'url_statuses') do |entry|
      entry.title(h(url_status.status))
      entry.content(h(url_status.description), :type => 'text')
    end
  end
end
