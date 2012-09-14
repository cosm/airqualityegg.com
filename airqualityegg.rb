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

  configure :production do
    require 'newrelic_rpm'
  end

  configure :development do
    register Sinatra::Reloader
  end

  helpers do
    def string_to_time(timestamp)
      Time.parse(timestamp).strftime("%d %b %Y %H:%M:%S")
    rescue
      ''
    end
  end

  # Render css from scss
  get '/style.css' do
    scss :style
  end

  # Home page
  get '/' do
    @error = session.delete(:error)
    @feeds = find_egg_feeds
    @map_markers = collect_map_markers(@feeds)
    erb :home
  end

  # Edit egg metadata
  get '/egg/:id/edit' do
    feed_id, api_key = extract_feed_id_and_api_key_from_session
    redirect_with_error('Not your egg') if feed_id.to_s != params[:id]
    response = Cosm::Client.get(feed_url(feed_id), :headers => {'Content-Type' => 'application/json', "X-ApiKey" => api_key})
    @feed = Cosm::Feed.new(response.body)
    erb :edit
  end

  # Register your egg
  post '/register' do
    begin
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

  # Update egg metadata
  post '/egg/:id/update' do
    feed_id, api_key = extract_feed_id_and_api_key_from_session
    redirect_with_error('Not your egg') if feed_id.to_s != params[:id]
    feed = Cosm::Feed.new({
      :title => params[:title],
      :id => feed_id,
      :private => false,
      :location_ele => params[:location_ele],
      :location_lat => params[:location_lat],
      :location_lon => params[:location_lon],
      :location_exposure => params[:location_exposure],
      :tags => "device:type=airqualityegg"
    })
    response = Cosm::Client.put(feed_url(feed_id), :headers => {'Content-Type' => 'application/json', "X-ApiKey" => api_key}, :body => feed.to_json)
    redirect "/egg/#{feed_id}"
  end

  # View egg dashboard
  get '/egg/:id' do
    response = Cosm::Client.get(feed_url(params[:id]), :headers => {"X-ApiKey" => $api_key})
    @feed = Cosm::Feed.new(response.body)
    @no2 = @feed.datastreams.detect{|d| d.id == "no2"}
    @co = @feed.datastreams.detect{|d| d.id == "co"}
    @temperature = @feed.datastreams.detect{|d| d.id == "temperature"}
    @humidity = @feed.datastreams.detect{|d| d.id == "humidity"}
    erb :show
  end

  private

  def extract_feed_id_and_api_key_from_session
    [session['response_json']['feed_id'], session['response_json']['apikey']]
  rescue
    redirect_with_error('Egg not found')
  end

  def find_egg_feeds
    response = Cosm::Client.get(feeds_url, :headers => {'Content-Type' => 'application/json', 'X-ApiKey' => $api_key})
    @feeds = Cosm::SearchResult.new(response.body).results
  rescue
    @feeds = Cosm::SearchResult.new().results
  end

  def feed_url(feed_id)
    "#{$api_url}/v2/feeds/#{feed_id}.json"
  end

  def collect_map_markers(feeds)
    MultiJson.dump(
      feeds.collect do |feed|
        {:feed_id => feed.id, :lat => feed.location_lat, :lng => feed.location_lon, :title => feed.title}.delete_if {|_,v| v.blank?}
      end
    )
  end

  def feeds_url
    "#{$api_url}/v2/feeds.json?tag=device%3Atype%3Dairqualityegg&amp;mapped=true"
  end

  def product_url
    redirect_with_error('Please enter a serial number') if params[:serial].blank?
    "#{$api_url}/v2/products/#{$product_id}/devices/#{params[:serial]}/activate"
  end

  def redirect_with_error(message)
    session['error'] = message
    redirect '/'
  end
end
