require 'spec_helper'

describe AirQualityEgg do

  it "should render the homepage" do
    get '/'
    last_response.should be_ok
    last_response.body.should =~ /Air Quality Egg/
  end

  describe 'registering' do

    it 'should render the dashboard if found' do
      request_stub = stub_request(:get, "https://api.cosm.com/v2/device_models/airqualityegg/devices/123").
        with(:headers => { 'X-ApiKey' => 'apikey'}).
        to_return(:status => 200, :body => '{"device":{"serial":"abcd","activated_at":null,"created_at":"2012-09-10T14:48:12Z","activation_code":"494ea17400d535a6824a8124d07cc3ba90a43556","feed_id":"45783"}}')
      post '/register', :serial => '123'
      request_stub.should have_been_made
      last_response.should be_redirect
      follow_redirect!
      last_request.url.should == "http://example.org/egg/45783"
    end

    it 'should handle unactivated eggs' do
      request_stub = stub_request(:get, "https://api.cosm.com/v2/device_models/airqualityegg/devices/123").
        with(:headers => { 'X-ApiKey' => 'apikey'}).
        to_return(:status => 200, :body => '{"device":{"serial":"abcd","activated_at":null,"created_at":"2012-09-10T14:48:12Z","activation_code":"494ea17400d535a6824a8124d07cc3ba90a43556","feed_id":null}}')
      post '/register', :serial => '123'
      request_stub.should have_been_made
      last_response.should be_redirect
      follow_redirect!
      last_request.url.should == "http://example.org/"
    end

    it 'should handle no serial' do
      post '/register'
      last_response.should be_redirect
      follow_redirect!
      last_request.url.should == "http://example.org/"
    end

    it 'should handle missing eggs' do
      request_stub = stub_request(:get, "https://api.cosm.com/v2/device_models/airqualityegg/devices/123").
        with(:headers => { 'X-ApiKey' => 'apikey'}).
        to_return(:status => 404, :body => "{\"errors\":\"I'm sorry we are unable to find the device you are looking for.\",\"title\":\"Not found\"}")
      post '/register', :serial => '123'
      request_stub.should have_been_made
      last_response.should be_redirect
      follow_redirect!
      last_request.url.should == "http://example.org/"
    end

  end

end
