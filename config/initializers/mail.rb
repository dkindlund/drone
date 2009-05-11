ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address => "mail.speakeasy.net",
  :port => 25,
  :domain => "drone.honeyclient.org",
}
