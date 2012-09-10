ENV['PRODUCT_ID'] = "airqualityegg"
ENV['API_KEY'] = "apikey"

require File.dirname(__FILE__) + '/../airqualityegg'

require 'rspec'
require 'rack/test'
require 'webmock/rspec'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

def app
  AirQualityEgg
end
