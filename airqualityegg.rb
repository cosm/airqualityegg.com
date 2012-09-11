require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/reloader' if Sinatra::Base.development?
require 'sass'
require 'cosm-rb'

class AirQualityEgg < Sinatra::Base

  configure do
    enable :sessions
    enable :logging
    $product_id = ENV['PRODUCT_ID']
    $api_key = ENV['API_KEY']
    $api_url = ENV['API_URL'] || Cosm::Client.base_uri

    raise "PRODUCT_ID not set" if $product_id.nil?
    raise "API_KEY not set" if $api_key.nil?
    raise "API_URL not set" if $api_url.nil?
    puts "WARN: You should set a SESSION_SECRET" unless ENV['SESSION_SECRET']

    set :session_secret, ENV['SESSION_SECRET'] || 'airqualityegg_session_secret'
  end

  configure :development do
    register Sinatra::Reloader
  end

  get '/style.css' do
    scss :style
  end

  get '/' do
    @error = session.delete(:error)
    erb :home
  end

  get '/egg/:id/edit' do
    feed_id, api_key = extract_feed_id_and_api_key_from_session
    response = Cosm::Client.get(feed_url(feed_id), :headers => {'Content-Type' => 'application/json', "X-ApiKey" => api_key})
    @feed = Cosm::Feed.new(response.body)
    erb :edit
  end

  post '/register' do
    begin
      raise "Egg not found" if params[:serial].blank?
      logger.info("GET: #{product_url}")
      response = Cosm::Client.get(product_url, :headers => {'Content-Type' => 'application/json', "X-ApiKey" => $api_key})
      json = MultiJson.load(response.body)
      session['response_json'] = json
      feed_id, api_key = extract_feed_id_and_api_key_from_session
      redirect_with_error("Egg not found") unless feed_id
      redirect "/egg/#{feed_id}/edit"
    rescue
      redirect_with_error "Egg not found"
    end
  end

  post '/egg/:id/update' do
    feed_id, api_key = extract_feed_id_and_api_key_from_session
    feed = Cosm::Feed.new(:title => params[:title], :id => feed_id)
    response = Cosm::Client.put(feed_url(feed_id), :headers => {'Content-Type' => 'application/json', "X-ApiKey" => api_key}, :body => feed.to_json)
    redirect "/egg/#{feed_id}"
  end

  get '/egg/:id' do
    feed_id, api_key = extract_feed_id_and_api_key_from_session
    response = Cosm::Client.get(feed_url(feed_id), :headers => {"X-ApiKey" => api_key})
    @feed = Cosm::Feed.new(response.body)
    erb :show
  end

  private

  def extract_feed_id_and_api_key_from_session
    [session['response_json']['feed_id'], session['response_json']['apikey']]
  end

  def feed_url(feed_id)
    "#{$api_url}/v2/feeds/#{feed_id}.json"
  end

  def product_url
    "#{$api_url}/v2/products/#{$product_id}/devices/#{params[:serial]}/activate"
  end

  def redirect_with_error(message)
    session['error'] = message
    redirect '/'
  end
end
