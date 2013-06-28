require 'spec_helper'

describe LogExcerptsController do
  
  describe "DELETE" do
    
    before do
      Api.stub!(:permitted?).and_return(double(:status => 200, 
                                               :body => {'authentication' => {'user_id' => 123}}))
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "so-totally-fake"
    end

    
    it "should return JSON" do
      delete :destroy, from: 0, to: 100000000
      response.content_type.should == "application/json"
    end

    it "should return a 400 if the X-API-Token header is missing" do
      Api.stub!(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      request.headers['X-API-Token'] = nil
      delete :destroy, from: 0, to: 100000000
      response.status.should == 400
    end
    
    it "should return a 400 if the authentication represented by the X-API-Token can't be found" do
      Api.stub!(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      request.headers['X-API-Token'] = 'unknown, matey'
      delete :destroy, from: 0, to: 100000000
      response.status.should == 400
      response.content_type.should == "application/json"
    end

    it "should return a 403 if the X-API-Token doesn't yield DELETE authorisation" do
      Api.stub!(:permitted?).and_return(double(:status => 403, :body => {:_api_error => []}))
      delete :destroy, from: 0, to: 100000000
      response.status.should == 403
      response.content_type.should == "application/json"
    end
        
    it "should return a 204 when successful" do
      delete :destroy, from: 0, to: 100000000
      response.status.should == 204
      response.content_type.should == "application/json"
    end
        
  end
  
end
