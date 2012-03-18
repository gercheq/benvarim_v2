class ForceSSL
  STARTS_WITH_WWW = /^www\./i
  def initialize(app)
    @app = app
  end

  def call(env)
    if env['SERVER_NAME'] == 'localhost'  || (env['HTTP_HOST'] =~ STARTS_WITH_WWW && (env['HTTPS'] == 'on' || env['HTTP_X_FORWARDED_PROTO'] == 'https'))
      @app.call(env)
    else
      req = Rack::Request.new(env)
      [301, { "Location" => req.url.gsub(/^http:/, "https:").gsub(/^https:\/\/benvarim.com/, "https://www.benvarim.com") }, []]
    end
  end
end