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
      expect($redis).to receive(:zadd)
      post :create, @valid_args
      expect(response.content_type).to eq("application/json")
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      expect($redis).not_to receive(:zadd)
      request.headers['X-API-Token'] = nil
      post :create, @valid_args
      expect(response.status).to eq(400)
      expect(response.content_type).to eq("application/json")
    end
    
    it "should return a 400 if the authentication represented by the X-API-Token can't be found" do
      expect($redis).not_to receive(:zadd)
      request.headers['X-API-Token'] = 'unknown, matey'
      allow(Api).to receive(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      post :create, @valid_args
      expect(response.status).to eq(400)
      expect(response.content_type).to eq("application/json")
    end

    it "should return a 403 if the X-API-Token doesn't yield GET authorisation" do
      expect($redis).not_to receive(:zadd)
      allow(Api).to receive(:permitted?).and_return(double(:status => 403, :body => {:_api_error => []}))
      post :create, @valid_args
      expect(response.status).to eq(403)
      expect(response.content_type).to eq("application/json")
    end
        
    it "should return a 422 when there are validation errors" do
      expect($redis).not_to receive(:zadd)
      post :create, @valid_args.merge("service" => nil, "level" => nil, "msg" => [1,2,3])
      expect(response.status).to eq(422)
      expect(response.content_type).to eq("application/json")
      expect(JSON.parse(response.body)).to eq({"service"=>["must be present", "must be a string"], 
      	                                   "level"=>["must be present", "must be an integer"],
      	                                   "msg"=>["must be a string"]})
    end
                
    it "should store all the params except controller and action when successful" do
      expect($redis).to receive(:zadd).with(
      	"log", 1234567890, 
      	'{"timestamp":1234567890,"ip":"123.123.123.123","pid":7890,"service":"some_service","level":1,"msg":"This is the log line."}'
      )
      post :create, @valid_args
      expect(response.status).to eq(204)
    end

    it "should return a 204 when successful" do
      expect($redis).to receive(:zadd)
      post :create, @valid_args
      expect(response.status).to eq(204)
    end

    it "should NOT contain a Location header when successful" do
      expect($redis).to receive(:zadd)
      post :create, @valid_args
      expect(response.headers['Location']).to eq(nil)
    end

    it "should NOT return the new resource in the body when successful" do
      expect($redis).to receive(:zadd)
      post :create, @valid_args
      expect(response.body.blank?).to eq(true)
    end

  end
end
