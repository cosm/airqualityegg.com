ENV['PRODUCT_ID'] = "airqualityegg"
ENV['API_KEY'] = "apikey"
ENV['API_URL'] = "http://api.cosm.com"

require File.dirname(__FILE__) + '/../airqualityegg'

require 'rspec'
require 'capybara/rspec'
require 'webmock/rspec'

Capybara.app = AirQualityEgg
WebMock.disable_net_connect!
