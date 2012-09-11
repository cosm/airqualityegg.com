require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'
require 'cosm-rb'

class AirQualityEgg < Sinatra::Base

  configure do
    enable :sessions
    $product_id = ENV['PRODUCT_ID']
    $api_key = ENV['API_KEY']
    $api_url = ENV['API_URL'] || Cosm::Client.base_uri

    raise "PRODUCT_ID not set" if $product_id.nil?
    raise "API_KEY not set" if $api_key.nil?
    raise "API_URL not set" if $api_url.nil?
    puts "WARN: You should set a SESSION_SECRET" unless ENV['SESSION_SECRET']

    set :session_secret, ENV['SESSION_SECRET'] || 'airqualityegg_session_secret'
  end

  get '/' do
    erb :home
  end

  post '/register' do
    redirect '/' if params[:serial].blank?
    url = "#{$api_url}/v2/products/#{$product_id}/devices/#{params[:serial]}/activate"
    response = Cosm::Client.get(url, :headers => {"X-ApiKey" => $api_key})
    begin
      json = MultiJson.load(response.body)
      session['response_json'] = json
      feed_id = json['feed_id']
      api_key = json['apikey']
      redirect feed_id ? "/egg/#{feed_id}/edit" : "/"
    rescue
      redirect '/'
    end
  end
end
