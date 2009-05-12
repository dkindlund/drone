# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_drone.honeyclient.org_session',
  :secret      => '9a52482bba4f5c9d977b8cf1ed91c1a607dcf01f6cd3884e12fbf0a3abc7d37863bdab83c82b5b8e53e108270e9a6518638a4a18ca94e31e048bd795433ce563'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
