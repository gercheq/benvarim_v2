Benvarim::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true


  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # devise needs action mailer
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }

  # Paperclip.options[:command_path] = "/opt/local/bin/identify"
  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.sendmail_settings = {:arguments => '-i'}

  #paypal settings
  ENV['PAYPAL_URL'] = 'https://www.sandbox.paypal.com/cgi-bin/webscr'
  ENV['PAYPAL_IPN_URL'] = 'http://www.sandbox.paypal.com/cgi-bin/webscr'
  ENV['PAYPAL_CURRENCY'] = 'USD'
  #these user and id token are used in db import script to update paypal user data.
  ENV['PAYPAL_SANDBOX_USER']= 'satis_1298099260_biz@benvarim.com'
  ENV['PAYPAL_ID_TOKEN'] = 'r97EMyFtFL6r3bu1ETAacEQYMUeLw6NusWWsDoKb8ER1-hXdzSQ9RByY2hq'

  #facebook settings
  ENV['FACEBOOK_APP_ID'] = "137649746329130"
  ENV['FACEBOOK_SECRET'] = "6e50bfd342289a64457fdc6289903f2c"

  #indextank settings
  # ENV['INDEXTANK_API_URL'] = 'http://:m8Qc52GryxmiN7@qgx.api.indextank.com'
  # ENV['INDEXTANK_PUBLIC_URL'] = 'http://qgx.api.indextank.com'
  #searchify urls
  ENV['SEARCHIFY_API_URL'] = "http://:cFmhDROc7SEKSa@aiaa.api.searchify.com"
  ENV['SEARCHIFY_PUBLIC_URL'] = "http://aiaa.api.searchify.com"

  ENV['ec_key'] = "1stabluE5"
end

