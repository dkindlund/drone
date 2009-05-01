# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_drone.honeyclient.org_session',
  :secret      => '24bbf65b18a77abd4a15ce10c0b08c36a85e8e2ae6e55c164721cf7e533a7a54113b65d77ff2cac9117792d18e17a58808457c2e3c31cbe78125904d18100fc8'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
