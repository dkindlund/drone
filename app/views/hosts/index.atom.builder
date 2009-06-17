atom_feed(:schema_date => "2009-06-16") do |feed|
  feed.title(Configuration.find_retry(:name => "atom.title_prefix", :namespace => controller.controller_name.camelize.singularize).to_s + Configuration.find_retry(:name => "atom.title", :namespace => controller.controller_name.camelize.singularize).to_s)
  feed.updated(@hosts.first.updated_at)
  feed.subtitle(Configuration.find_retry(:name => "atom.description", :namespace => controller.controller_name.camelize.singularize).to_s)

  for host in @hosts
    feed.entry(host) do |entry|
      entry.title(host.hostname)
      entry.content(host.ip, :type => 'text')
    end
  end
end
