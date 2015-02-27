require 'spec_helper'

describe LogExcerptsController do
  
  describe "DELETE" do
    
    before do
      permit_with 200
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "so-totally-fake"
    end

    
    it "should return JSON" do
      delete :destroy, from: 0, to: 100000000
      expect(response.content_type).to eq("application/json")
    end

    it "should return a 400 if the X-API-Token header is missing" do
      allow(Api).to receive(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      request.headers['X-API-Token'] = nil
      delete :destroy, from: 0, to: 100000000
      expect(response.status).to eq(400)
    end
    
    it "should return a 400 if the authentication represented by the X-API-Token can't be found" do
      allow(Api).to receive(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      request.headers['X-API-Token'] = 'unknown, matey'
      delete :destroy, from: 0, to: 100000000
      expect(response.status).to eq(400)
      expect(response.content_type).to eq("application/json")
    end

    it "should return a 403 if the X-API-Token doesn't yield DELETE authorisation" do
      allow(Api).to receive(:permitted?).and_return(double(:status => 403, :body => {:_api_error => []}))
      delete :destroy, from: 0, to: 100000000
      expect(response.status).to eq(403)
      expect(response.content_type).to eq("application/json")
    end
        
    it "should return a 204 when successful" do
      delete :destroy, from: 0, to: 100000000
      expect(response.status).to eq(204)
      expect(response.content_type).to eq("application/json")
    end
        
  end
  
end
