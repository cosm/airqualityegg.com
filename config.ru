require './airqualityegg'
require 'rack/force_domain'
use Rack::ForceDomain, ENV['FORCE_DOMAIN'] if ENV['FORCE_DOMAIN']
run AirQualityEgg
