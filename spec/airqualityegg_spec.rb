require 'spec_helper'

describe AirQualityEgg do

  it "should render the homepage" do
    get '/'
    last_response.should be_ok
    last_response.body.should =~ /Air Quality Egg/
  end

  describe 'registering' do

    it 'should render the dashboard if found' do
      request_stub = stub_request(:get, "http://api.cosm.com/v2/products/airqualityegg/devices/123/activate").
        with(:headers => { 'X-ApiKey' => 'apikey'}).
        to_return(:status => 200, :body => MultiJson.dump({"datastreams"=>[], "feed_id"=>101, "apikey"=>"HSA8lzxDe-uOigbz8Ic_syfuGsaSAKxjcUZMS3NTbXJhWT0g"}))
      post '/register', :serial => '123'
      request_stub.should have_been_made
      last_response.should be_redirect
      follow_redirect!
      last_request.url.should == "http://example.org/egg/101/edit"
    end

    it 'should handle no serial' do
      post '/register'
      last_response.should be_redirect
      follow_redirect!
      last_request.url.should == "http://example.org/"
    end

    it 'should handle missing eggs' do
      request_stub = stub_request(:get, "http://api.cosm.com/v2/products/airqualityegg/devices/123/activate").
        with(:headers => { 'X-ApiKey' => 'apikey'}).
        to_return(:status => 404, :body => MultiJson.dump({"title"=>"Not found", "errors"=>"I'm sorry we are unable to find the device you are looking for."}))
      post '/register', :serial => '123'
      request_stub.should have_been_made
      last_response.should be_redirect
      follow_redirect!
      last_request.url.should == "http://example.org/"
    end

  end

end
