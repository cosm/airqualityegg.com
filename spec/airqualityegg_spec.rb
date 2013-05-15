require 'spec_helper'

describe AirQualityEgg, :type => :request do

  before do
    WebMock.reset!
    map_request = stub_request(:get, "http://api.cosm.com/v2/feeds.json?amp;mapped=true&tag=device:type=airqualityegg").
      with(:headers => {'Content-Type'=>'application/json', 'X-Apikey'=>'apikey'}).
      to_return(:status => 200, :body => '{"itemsPerPage":100,"results":[],"totalResults":0,"startIndex":0}', :headers => {})
  end

  it "should render the homepage" do
    visit '/'
    page.find('.branding-logo').should have_content "Air Quality Egg"
    page.should have_content "Community-led sensing network"
  end

  it "should render the homepage even if the feed search fails" do
    WebMock.reset!
    map_request = stub_request(:get, "http://api.cosm.com/v2/feeds.json?amp;mapped=true&tag=device:type=airqualityegg").
      to_return(:status => 500, :body => 'error', :headers => {})
    visit '/'
    page.find('.branding-logo').should have_content "Air Quality Egg"
  end

  describe 'registering' do

    it 'should render the edit form if found' do
      stub_request(:get, "http://api.cosm.com/v2/feeds/101.json").
        with(:headers => { 'X-ApiKey' => 'HSA8lzxDe-uOigbz8Ic_syfuGsaSAKxjcUZMS3NTbXJhWT0g' }).
        to_return(:status => 200, :body => Xively::Feed.new(:title => "Joe's Air Quality Egg", :id => 101).to_json)
      stub_request(:get, "http://api.cosm.com/v2/products/airqualityegg/devices/123/activate").
        with(:headers => { 'X-ApiKey' => 'apikey'}).
        to_return(:status => 200, :body => MultiJson.dump({"datastreams"=>[], "feed_id"=>101, "apikey"=>"HSA8lzxDe-uOigbz8Ic_syfuGsaSAKxjcUZMS3NTbXJhWT0g"}))
      visit '/'
      fill_in 'serial', :with => '123'
      click_button 'Add my egg'
      current_path.should == "/egg/101/edit"
    end

    it "should downcase serial before activating" do
      stub_request(:get, "http://api.cosm.com/v2/feeds/101.json").
        with(:headers => { 'X-ApiKey' => 'HSA8lzxDe-uOigbz8Ic_syfuGsaSAKxjcUZMS3NTbXJhWT0g' }).
        to_return(:status => 200, :body => Xively::Feed.new(:title => "Joe's Air Quality Egg", :id => 101).to_json)
      stub_request(:get, "http://api.cosm.com/v2/products/airqualityegg/devices/ab:12:cd:34:ef:56/activate").
        with(:headers => { 'X-ApiKey' => 'apikey'}).
        to_return(:status => 200, :body => MultiJson.dump({"datastreams"=>[], "feed_id"=>101, "apikey"=>"HSA8lzxDe-uOigbz8Ic_syfuGsaSAKxjcUZMS3NTbXJhWT0g"}))
      visit '/'
      fill_in 'serial', :with => 'AB:12:CD:34:EF:56'
      click_button 'Add my egg'
      current_path.should == "/egg/101/edit"
    end

    it 'should handle no serial' do
      visit '/'
      fill_in 'serial', :with => ''
      click_button 'Add my egg'
      page.should have_content("Please enter a serial number")
      current_path.should == "/"
    end

    it 'should handle missing eggs' do
      request_stub = stub_request(:get, "http://api.cosm.com/v2/products/airqualityegg/devices/123/activate").
        with(:headers => { 'X-ApiKey' => 'apikey'}).
        to_return(:status => 404, :body => MultiJson.dump({"title"=>"Not found", "errors"=>"I'm sorry we are unable to find the device you are looking for."}))
      visit '/'
      fill_in 'serial', :with => '123'
      click_button 'Add my egg'
      page.should have_content("Egg not found")
      current_path.should == "/"
    end

  end

  describe 'editing' do

    it "should redirect and error if not in session" do
      visit '/egg/17/edit'
      page.should have_content "Air Quality Egg"
      current_path.should == '/'
    end

    context "after registering" do
      before do
        stub_request(:get, "http://api.cosm.com/v2/products/airqualityegg/devices/123/activate").
          with(:headers => { 'X-ApiKey' => 'apikey'}).
          to_return(:status => 200, :body => MultiJson.dump({"datastreams"=>[], "feed_id"=>101, "apikey"=>"HSA8lzxDe-uOigbz8Ic_syfuGsaSAKxjcUZMS3NTbXJhWT0g"}))
        stub_request(:get, "http://api.cosm.com/v2/feeds/101.json").
          with(:headers => { 'X-ApiKey' => 'HSA8lzxDe-uOigbz8Ic_syfuGsaSAKxjcUZMS3NTbXJhWT0g' }).
          to_return(:status => 200, :body => Xively::Feed.new(:title => "Joe's Air Quality Egg", :id => 101, :tags => 'airqualityegg').to_json)
        stub_request(:get, "http://api.cosm.com/v2/feeds/101.json").
          with(:headers => { 'X-ApiKey' => 'apikey' }).
          to_return(:status => 200, :body => Xively::Feed.new(:title => "Joe's London based egg", :id => 101).to_json)
        visit '/'
        fill_in 'serial', :with => '123'
        click_button 'Add my egg'
      end

      it 'should render the form' do
        page.should have_field('title', :with => "Joe's Air Quality Egg")
        current_path.should == '/egg/101/edit'
      end

      it 'should allow updating the egg and render the dashboard' do
        stub_request(:put, "http://api.cosm.com/v2/feeds/101.json").
          with(:headers => { 'X-ApiKey' => 'HSA8lzxDe-uOigbz8Ic_syfuGsaSAKxjcUZMS3NTbXJhWT0g' },
               :body => {"id" => 101,"title" => "Joe's London based egg","description" => "I built this egg with rock and roll","version" => "1.0.0", "private" => "false", "location" => {"lat" => "51.5081289", "lon" => "-0.12800500000003012", "exposure" => "indoor"}, "tags" => ["airqualityegg", "device:type=airqualityegg"]}).
          to_return(:status => 200, :body => "")
        fill_in 'title', :with => "Joe's London based egg"
        fill_in 'description', :with => "I built this egg with rock and roll"
        select 'Indoor', :from => 'Exposure'
        click_button 'Save'
        page.should have_content "Joe's London based egg"
        current_path.should == "/egg/101"
      end

      it 'should not allow editing another egg' do
        visit '/egg/999/edit'
        page.should have_content('Not your egg')
        current_path.should == '/'
      end
    end
  end

  describe 'dashboard' do
    before do
      stub_request(:get, "http://api.cosm.com/v2/feeds/101.json").
        with(:headers => { 'X-ApiKey' => 'apikey' }).
        to_return(:status => 200, :body => egg_json)
    end

    it 'should render the dashboard' do
      visit '/egg/101'
      page.find('h1.metadata-feed-title').should have_content("Joe's Air Quality Egg")
      current_path.should == '/egg/101'
      within('div.current-no2') do
        page.should have_content('125')
      end
      within('div.current-co') do
        page.should have_content('270023')
      end
      within('div.current-temperature') do
        page.should have_content('22')
      end
      within('div.current-humidity') do
        page.should have_content('70')
      end
    end

    it "should not render a 500 error if return json doesn't have tags for every datastream" do
      stub_request(:get, "http://api.cosm.com/v2/feeds/101.json").
        with(:headers => { 'X-ApiKey' => 'apikey' }).
        to_return(:status => 200, :body => no_tag_json)
      visit "/egg/101"
      page.find('h1.metadata-feed-title').should have_content("Joe's Air Quality Egg")
      current_path.should == '/egg/101'
      within('div.current-no2') do
        page.should have_content('125')
      end
      within('div.current-co') do
        page.should have_content('270023')
      end
      within('div.current-temperature') do
        page.should have_content('22')
      end
      within('div.current-humidity') do
        page.should have_content('70')
      end
    end
  end
end
