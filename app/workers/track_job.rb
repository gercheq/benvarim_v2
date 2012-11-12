require 'net/http'
require 'rubygems'
class TrackJob
  include HerokuDelayedJobAutoscale::Autoscale
  attr_accessor :event_name, :properties, :super_properties

  def initialize (event_name, properties = {}, super_properties = {})
    self.event_name = event_name
    self.properties = properties
    self.super_properties = super_properties

    self.properties = {} if self.properties.nil?
    self.super_properties = {} if self.super_properties.nil?
    puts "tracking event #{event_name}"
  end

  def perform
    props = {}
    props.merge! self.super_properties
    props.merge! self.properties
    params = {"event" => event_name, "properties" => props}
    self.send_query params
  end

  def send_query hash
    puts "tracking #{hash}"
    data = ActiveSupport::Base64.encode64s(JSON.generate(hash))
    url = "http://api.mixpanel.com/track/?data=#{data}"
    response = Net::HTTP.get_response(URI.parse(url)).body
  end
end