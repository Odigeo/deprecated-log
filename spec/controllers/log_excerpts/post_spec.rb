require 'spec_helper'

describe LogExcerptsController do
  
  describe "POST" do
    
    before :each do
      permit_with 200
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "totally-fake"
      @valid_args = {"timestamp" => 1234567890, "ip" => "123.123.123.123", "pid" => 7890,
                     "service" => "some_service", "level" => 1, "msg" => "This is the log line."}
    end


    it "should return JSON" do
      $redis.should_receive(:zadd)
      post :create, @valid_args
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      $redis.should_not_receive(:zadd)
      request.headers['X-API-Token'] = nil
      post :create, @valid_args
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the authentication represented by the X-API-Token can't be found" do
      $redis.should_not_receive(:zadd)
      request.headers['X-API-Token'] = 'unknown, matey'
      Api.stub(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      post :create, @valid_args
      response.status.should == 400
      response.content_type.should == "application/json"
    end

    it "should return a 403 if the X-API-Token doesn't yield GET authorisation" do
      $redis.should_not_receive(:zadd)
      Api.stub(:permitted?).and_return(double(:status => 403, :body => {:_api_error => []}))
      post :create, @valid_args
      response.status.should == 403
      response.content_type.should == "application/json"
    end
        
    it "should return a 422 when there are validation errors" do
      $redis.should_not_receive(:zadd)
      post :create, @valid_args.merge("service" => nil, "level" => nil, "msg" => [1,2,3])
      response.status.should == 422
      response.content_type.should == "application/json"
      JSON.parse(response.body).should == {"service"=>["must be present", "must be a string"], 
      	                                   "level"=>["must be present", "must be an integer"],
      	                                   "msg"=>["must be a string"]}
    end
                
    it "should store all the params except controller and action when successful" do
      $redis.should_receive(:zadd).with(
      	"log", 1234567890, 
      	'{"timestamp":1234567890,"ip":"123.123.123.123","pid":7890,"service":"some_service","level":1,"msg":"This is the log line."}'
      )
      post :create, @valid_args
      response.status.should == 204
    end

    it "should return a 204 when successful" do
      $redis.should_receive(:zadd)
      post :create, @valid_args
      response.status.should == 204
    end

    it "should NOT contain a Location header when successful" do
      $redis.should_receive(:zadd)
      post :create, @valid_args
      response.headers['Location'].should == nil
    end

    it "should NOT return the new resource in the body when successful" do
      $redis.should_receive(:zadd)
      post :create, @valid_args
      response.body.blank?.should == true
    end

  end
end
