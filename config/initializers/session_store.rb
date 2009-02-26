# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_drone.honeyclient.org_session',
  :secret      => 'f356975b5ea2b1d3718d416b41c733531430172399c7c5f6aedfe377197d41c4d751f9c4e13c5a50ffaed2931e4ce4e24fdf3bee1dcffbcce1b1f058b8ba8563'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
