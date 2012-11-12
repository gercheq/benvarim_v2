require 'net/http'
require 'rubygems'
class TrackUserJob
  include HerokuDelayedJobAutoscale::Autoscale
  attr_accessor :uid

  def initialize (uid)
    self.uid = uid
  end

  def perform
    user = User.find_by_id uid
    if user.nil?
      #wtf ?
      return
    end
    props = {
      "$set" => {
        "$email"  => user.email,
        "$created" => user.created_at,
        "birthday"  => user.birthday,
        "updated_at" => user.updated_at,
        "username"  => user.cached_slug,
        "$first_name"  => user.name,
        "total_fundraised"  => user.total_fundraised,
        "payments_count"  => user.payments.count,
        "total_donated"  => user.total_donated,
        "total_supporters"  => user.total_supporters,
        "tracked" => Time.now,
        "age"  => user.age
      },
      "$distinct_id"  => user.id,
      "$token" => ENV['MIXPANEL_TOKEN']
    }
    self.send_query props
  end

  def send_query hash
    puts "tracking #{hash}"
    data = ActiveSupport::Base64.encode64s(JSON.generate(hash))
    url = "http://api.mixpanel.com/engage/?data=#{data}"
    puts url
    response = Net::HTTP.get_response(URI.parse(url)).body
  end
end