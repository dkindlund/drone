# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_drone.honeyclient.org_session',
  :secret      => '2a15e5ea2f9b1ffdf0587c4e143d550f3d2ab3b919dd57c39ebfd8d33dfd7afa68a321f7f31f89b77a852c052ac9571f8f7aab5a4d24cff01fd3d734f5077a0d'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
