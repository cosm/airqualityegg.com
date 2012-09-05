require File.dirname(__FILE__) + '/../airqualityegg'

require 'rspec'
require 'rack/test'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

def app
  AirQualityEgg
end
