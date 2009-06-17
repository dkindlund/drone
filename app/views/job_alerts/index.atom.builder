atom_feed(:schema_date => "2009-06-16") do |feed|
  feed.title(Configuration.find_retry(:name => "atom.title_prefix", :namespace => controller.controller_name.camelize.singularize).to_s + Configuration.find_retry(:name => "atom.title", :namespace => controller.controller_name.camelize.singularize).to_s)
  feed.subtitle(Configuration.find_retry(:name => "atom.description", :namespace => controller.controller_name.camelize.singularize).to_s)

  for job_alert in @job_alerts
    feed.entry(job_alert) do |entry|
      entry.title(job_alert.address)
      entry.content("Protocol: #{job_alert.protocol}", :type => 'text')
    end
  end
end
