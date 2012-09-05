require 'spec_helper'

describe AirQualityEgg do

  it "should hello world" do
    get '/'
    last_response.should be_ok
    last_response.body.should == 'Hello world'
  end

end
