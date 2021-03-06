# Be sure to restart your server when you modify this file

# Use production mode, by default.
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem "guid"
  config.gem "eventmachine"
  config.gem "amqp"
  config.gem "rubyist-aasm", :lib => "aasm", :source => "http://gems.github.com"
  config.gem "ferret"
  config.gem "acts_as_ferret"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  config.active_record.observers = :user_observer, :url_observer
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # Preserve MySQL specific indexing in the generated schema.
  config.active_record.schema_format = :sql

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :info

  # Configure the default logger.
  # config.logger = Logger.new

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de

  # Specify that the RubyInline directory should be beneath the rails root.
  ENV['INLINEDIR'] = RAILS_ROOT
end

# XXX: Update this, accordingly.
SITE_DOMAIN = "drone.honeyclient.org"
SITE_URL = "https://#{SITE_DOMAIN}"
ADMIN_EMAIL = "noreply@#{SITE_DOMAIN}"

# Specify what address the notifications will be sent from.
ExceptionNotifier.sender_address = %("Exception Notifier" <#{ADMIN_EMAIL}>)
ExceptionNotifier.email_prefix = "[#{SITE_DOMAIN}] "

# Specify who will receive email notifications when exceptions occur.
ExceptionNotifier.exception_recipients = %w(darien@kindlund.com)
