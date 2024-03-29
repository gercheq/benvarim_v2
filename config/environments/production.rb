Benvarim::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.action_mailer.default_url_options = { :host => 'www.benvarim.com' }

  ENV['PAYPAL_URL'] = 'https://www.paypal.com/cgi-bin/webscr'
  ENV['PAYPAL_IPN_URL'] = 'http://www.paypal.com/cgi-bin/webscr'
  ENV['PAYPAL_CURRENCY'] = 'TRY'

  #facebook settings
  ENV['FACEBOOK_APP_ID'] = "116309391796241"
  ENV['FACEBOOK_SECRET'] = "c50d6f39391f55efd2f226a9ead420ad"

  #indextank settings
  ENV['INDEXTANK_PUBLIC_URL'] = 'https://2jean.api.indextank.com'
  ENV['SEARCHIFY_PUBLIC_URL'] = 'https://8ip51.api.searchify.com'
  ENV['SEARCHIFY_API_URL'] = 'https://:nxtZWMWywhe270@8ip51.api.searchify.com'

  ENV['YKPOSTNET_URL'] = "https://www.posnet.ykb.com/3DSWebService/OOS";

  # mixpanel
  ENV['MIXPANEL_TOKEN'] = '560aa9cfca7da5a5fac094ab7abd27f6'
end
