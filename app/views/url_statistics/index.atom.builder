atom_feed(:schema_date => "2009-06-16") do |feed|
  feed.title(h(Configuration.find_retry(:name => "atom.title_prefix", :namespace => controller.controller_name.camelize.singularize).to_s) + h(Configuration.find_retry(:name => "atom.title", :namespace => controller.controller_name.camelize.singularize).to_s))
  if (!@url_statistics.first.nil?)
    feed.updated(@url_statistics.first.updated_at)
  end
  feed.subtitle(h(Configuration.find_retry(:name => "atom.description", :namespace => controller.controller_name.camelize.singularize).to_s))

  for url_statistic in @url_statistics
    feed.entry(url_statistic) do |entry|
      entry.title(h(url_statistic.url_status.status.to_s) + " - " + h(url_statistic.count.to_s))
      entry.updated(url_statistic.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ"))
      entry.content :type => 'xhtml' do |xhtml|
        xhtml.p {
          xhtml.text! "URL Status: #{h(url_statistic.url_status.status)}"; xhtml.br
          xhtml.text! "From: #{h(url_statistic.created_at)}"; xhtml.br
          xhtml.text! "To: #{h(url_statistic.updated_at)}"; xhtml.br
          xhtml.text! "Count: #{h(url_statistic.count)}"; xhtml.br
        }
      end
    end
  end
end
