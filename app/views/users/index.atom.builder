atom_feed(:schema_date => "2009-06-16") do |feed|
  feed.title(h(Configuration.find_retry(:name => "atom.title_prefix", :namespace => controller.controller_name.camelize.singularize).to_s) + h(Configuration.find_retry(:name => "atom.title", :namespace => controller.controller_name.camelize.singularize).to_s))
  if (!@users.first.nil?)
    feed.updated(@users.first.updated_at)
  end
  feed.subtitle(h(Configuration.find_retry(:name => "atom.description", :namespace => controller.controller_name.camelize.singularize).to_s))

  for user in @users
    feed.entry(user) do |entry|
      entry.title(h(user.name))
      entry.updated(user.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ"))
      entry.content :type => 'xhtml' do |xhtml|
        xhtml.p {
          xhtml.text! "Login: #{h(user.login)}"; xhtml.br
          xhtml.text! "Email: #{h(user.email)}"; xhtml.br
          xhtml.text! "Organization: #{h(user.organization)}"; xhtml.br
          xhtml.text! "State: #{h(user.state)}"; xhtml.br
        }
      end
    end
  end
end
