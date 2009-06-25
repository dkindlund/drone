atom_feed(:schema_date => "2009-06-16") do |feed|
  feed.title(h(Configuration.find_retry(:name => "atom.title_prefix", :namespace => controller.controller_name.camelize.singularize).to_s) + h(Configuration.find_retry(:name => "atom.title", :namespace => controller.controller_name.camelize.singularize).to_s))
  if (!@hosts.first.nil?)
    feed.updated(@hosts.first.updated_at)
  end
  feed.subtitle(h(Configuration.find_retry(:name => "atom.description", :namespace => controller.controller_name.camelize.singularize).to_s))

  for host in @hosts
    feed.entry(host) do |entry|
      entry.title(h(host.hostname))
      entry.content(h(host.ip), :type => 'text')
    end
  end
end
