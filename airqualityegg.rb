require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'
require 'cosm-rb'

class AirQualityEgg < Sinatra::Base

  configure do
    $product_id = ENV['PRODUCT_ID']
    $api_key = ENV['API_KEY']
    $api_url = ENV['API_URL'] || Cosm::Client.base_uri

    raise "PRODUCT_ID not set" if $product_id.nil?
    raise "API_KEY not set" if $api_key.nil?
    raise "API_URL not set" if $api_url.nil?
  end


  get '/' do
    erb :home
  end

  post '/register' do
    redirect '/' if params[:serial].blank?
    url = "#{$api_url}/v2/device_models/#{$product_id}/devices/#{params[:serial]}"
    response = Cosm::Client.get(url, :headers => {"X-ApiKey" => $api_key})

    begin
      feed_id = MultiJson.load(response.body)['device']['feed_id']
      redirect feed_id ? "/egg/#{feed_id}" : "/"
    rescue
      redirect '/'
    end
  end
end
