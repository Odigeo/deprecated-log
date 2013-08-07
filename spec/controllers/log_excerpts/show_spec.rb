require 'spec_helper'

describe LogExcerptsController do
  
  describe "GET" do
    
    before :each do
      permit_with 200
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "totally-fake"
    end

    
    it "should return JSON" do
      $redis.should_receive(:zcount).once.and_return(0)
      $redis.should_receive(:zrangebyscore).once.and_return([])
      get :show, from: 0, to: 1000000000
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      $redis.should_not_receive(:zcount)
      $redis.should_not_receive(:zrangebyscore)
      request.headers['X-API-Token'] = nil
      get :show, from: 0, to: 1000000000
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the authentication represented by the X-API-Token can't be found" do
      $redis.should_not_receive(:zcount)
      $redis.should_not_receive(:zrangebyscore)
      request.headers['X-API-Token'] = 'unknown, matey'
      Api.stub(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      get :show, from: 0, to: 1000000000
      response.status.should == 400
      response.content_type.should == "application/json"
    end

    it "should return a 403 if the X-API-Token doesn't yield GET authorisation" do
      $redis.should_not_receive(:zcount)
      $redis.should_not_receive(:zrangebyscore)
      Api.stub(:permitted?).and_return(double(:status => 403, :body => {:_api_error => []}))
      get :show, from: 0, to: 1000000000
      response.status.should == 403
      response.content_type.should == "application/json"
    end
        
    it "should return a 200 when successful" do
      $redis.should_receive(:zcount).once.and_return(0)
      $redis.should_receive(:zrangebyscore).once.and_return([])
      get :show, from: 0, to: 1000000000
      response.status.should == 200
    end
    
  end
  
end
