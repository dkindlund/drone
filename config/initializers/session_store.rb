# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_drone.honeyclient.org_session',
  :secret      => '30dbc6b198cd5d15cded5c4a28e5719dacf0e83abc74037c5d394b5a4cf580f34ba424a4d10ef2406e1d1ed2545656cd53451dc3823c7cd53c5edd66ebaf879e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
