atom_feed(:schema_date => "2009-06-16") do |feed|
  feed.title(Configuration.find_retry(:name => "atom.title_prefix", :namespace => controller.controller_name.camelize.singularize).to_s + Configuration.find_retry(:name => "atom.title", :namespace => controller.controller_name.camelize.singularize).to_s)
  feed.subtitle(Configuration.find_retry(:name => "atom.description", :namespace => controller.controller_name.camelize.singularize).to_s)

  for client_status in @client_statuses
    feed.entry(client_status) do |entry|
      entry.title(client_status.status)
      entry.content(client_status.description, :type => 'text')
    end
  end
end
