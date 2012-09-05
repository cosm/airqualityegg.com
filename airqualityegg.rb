require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'

class AirQualityEgg < Sinatra::Base
  get '/' do
    'Hello world'
  end
end
