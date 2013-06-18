require 'spec_helper'

describe "long polling" do

  it "should not be done when the excerpt isn't empty" do
    ApplicationController.any_instance.stub(:require_x_api_token).and_return true
    ApplicationController.any_instance.stub(:authorize_action).and_return true
    $redis.should_receive(:zcount).once.and_return(3)
    $redis.should_receive(:zrangebyscore).once.and_return(["entry1", "entry2", "entry3"])
    get "/v1/log_excerpts/123/456", {}, {'HTTP_ACCEPT' => "application/json"}
    response.status.should be(200)
  end
  
  it "should not be done when ?long_polling=true isn't present" do
    ApplicationController.any_instance.stub(:require_x_api_token).and_return true
    ApplicationController.any_instance.stub(:authorize_action).and_return true
    $redis.should_receive(:zcount).once.and_return(0)
    $redis.should_receive(:zrangebyscore).once.and_return([])
    get "/v1/log_excerpts/123/456", {}, {'HTTP_ACCEPT' => "application/json"}
    response.status.should be(200)
  end
  
  it "should not be done when :to isn't in the future" do
    ApplicationController.any_instance.stub(:require_x_api_token).and_return true
    ApplicationController.any_instance.stub(:authorize_action).and_return true
    $redis.should_receive(:zcount).once.and_return(0)
    $redis.should_receive(:zrangebyscore).once.and_return([])
    to = ((Time.now.utc - 1.minute).to_f * 1000).to_i
    get "/v1/log_excerpts/123/#{to}", {long_polling: true}, {'HTTP_ACCEPT' => "application/json"}
    response.status.should be(200)
  end
  
  it "should be done when the excerpt is empty, long_polling is true, and to is in the future" do
    ApplicationController.any_instance.stub(:require_x_api_token).and_return true
    ApplicationController.any_instance.stub(:authorize_action).and_return true
    $redis.should_receive(:zcount).once.and_return(0)
    $redis.should_receive(:zrangebyscore).exactly(3).times.and_return([], [], ["new entry"])
    to = ((Time.now.utc + 1.minute).to_f * 1000).to_i
    get "/v1/log_excerpts/123/#{to}", {long_polling: true}, {'HTTP_ACCEPT' => "application/json"}
    response.status.should be(200)
  end
  

end
