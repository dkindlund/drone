atom_feed(:schema_date => "2009-06-16") do |feed|
  feed.title(Configuration.find_retry(:name => "atom.title_prefix", :namespace => controller.controller_name.camelize.singularize).to_s + Configuration.find_retry(:name => "atom.title", :namespace => controller.controller_name.camelize.singularize).to_s)
  feed.updated(@users.first.updated_at)
  feed.subtitle(Configuration.find_retry(:name => "atom.description", :namespace => controller.controller_name.camelize.singularize).to_s)

  for user in @users
    feed.entry(user) do |entry|
      entry.title(user.name)
      entry.updated(user.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ"))
      entry.content :type => 'xhtml' do |xhtml|
        xhtml.p {
          xhtml.text! "Login: #{user.login}"; xhtml.br
          xhtml.text! "Email: #{user.email}"; xhtml.br
          xhtml.text! "Organization: #{user.organization}"; xhtml.br
          xhtml.text! "State: #{user.state}"; xhtml.br
        }
      end
    end
  end
end
