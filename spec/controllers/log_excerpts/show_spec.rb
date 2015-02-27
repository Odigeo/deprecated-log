require 'spec_helper'

describe LogExcerptsController do
  
  describe "GET" do
    
    before :each do
      permit_with 200
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "totally-fake"
    end

    
    it "should return JSON" do
      expect($redis).to receive(:zcount).once.and_return(0)
      expect($redis).to receive(:zrangebyscore).once.and_return([])
      get :show, from: 0, to: 1000000000
      expect(response.content_type).to eq("application/json")
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      expect($redis).not_to receive(:zcount)
      expect($redis).not_to receive(:zrangebyscore)
      request.headers['X-API-Token'] = nil
      get :show, from: 0, to: 1000000000
      expect(response.status).to eq(400)
      expect(response.content_type).to eq("application/json")
    end
    
    it "should return a 400 if the authentication represented by the X-API-Token can't be found" do
      expect($redis).not_to receive(:zcount)
      expect($redis).not_to receive(:zrangebyscore)
      request.headers['X-API-Token'] = 'unknown, matey'
      allow(Api).to receive(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      get :show, from: 0, to: 1000000000
      expect(response.status).to eq(400)
      expect(response.content_type).to eq("application/json")
    end

    it "should return a 403 if the X-API-Token doesn't yield GET authorisation" do
      expect($redis).not_to receive(:zcount)
      expect($redis).not_to receive(:zrangebyscore)
      allow(Api).to receive(:permitted?).and_return(double(:status => 403, :body => {:_api_error => []}))
      get :show, from: 0, to: 1000000000
      expect(response.status).to eq(403)
      expect(response.content_type).to eq("application/json")
    end
        
    it "should return a 200 when successful" do
      expect($redis).to receive(:zcount).once.and_return(0)
      expect($redis).to receive(:zrangebyscore).once.and_return([])
      get :show, from: 0, to: 1000000000
      expect(response.status).to eq(200)
    end
    
  end
  
end
