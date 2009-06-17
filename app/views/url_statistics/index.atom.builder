atom_feed(:schema_date => "2009-06-16") do |feed|
  feed.title(Configuration.find_retry(:name => "atom.title_prefix", :namespace => controller.controller_name.camelize.singularize).to_s + Configuration.find_retry(:name => "atom.title", :namespace => controller.controller_name.camelize.singularize).to_s)
  feed.updated(@url_statistics.first.updated_at)
  feed.subtitle(Configuration.find_retry(:name => "atom.description", :namespace => controller.controller_name.camelize.singularize).to_s)

  for url_statistic in @url_statistics
    feed.entry(url_statistic) do |entry|
      entry.title(url_statistic.url_status.status.to_s + " - " + url_statistic.count.to_s)
      entry.updated(url_statistic.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ"))
      entry.content :type => 'xhtml' do |xhtml|
        xhtml.p {
          xhtml.text! "URL Status: #{url_statistic.url_status.status}"; xhtml.br
          xhtml.text! "From: #{url_statistic.created_at}"; xhtml.br
          xhtml.text! "To: #{url_statistic.updated_at}"; xhtml.br
          xhtml.text! "Count: #{url_statistic.count}"; xhtml.br
        }
      end
    end
  end
end
