require 'spec_helper'

describe TheModelsController do
  
  render_views

  describe "PUT" do
    
    before :each do
      Api.stub!(:permitted?).and_return(double(:status => 200, 
                                               :body => {'authentication' => {'user_id' => 123}}))
      request.env['HTTP_ACCEPT'] = "application/json"
      request.env['X-API-Token'] = "incredibly-fake!"
      @u = create :the_model
      @args = @u.attributes
    end
     

    it "should return JSON" do
      put :update, @args
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.env['X-API-Token'] = nil
      put :update, @args
      response.status.should == 400
    end

    it "should return a 400 if the authentication represented by the X-API-Token can't be found" do
      request.env['X-API-Token'] = 'unknown, matey'
      Api.stub!(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      put :update, @args
      response.status.should == 400
      response.content_type.should == "application/json"
    end

    it "should return a 403 if the X-API-Token doesn't yield PUT authorisation for ApiUsers" do
      Api.stub!(:permitted?).and_return(double(:status => 403, :body => {:_api_error => []}))
      put :update, @args
      response.status.should == 403
      response.content_type.should == "application/json"
    end

    it "should return a 404 if the resource can't be found" do
      put :update, id: -1
      response.status.should == 404
      response.content_type.should == "application/json"
    end

    it "should return a 422 when resource properties are missing (all must be set simultaneously)" do
      put :update, id: @u.id
      response.status.should == 422
      response.content_type.should == "application/json"
    end

    it "should return a 409 when there is an update conflict" do
      @u.update_attributes!({updated_at: 1.week.from_now}, :without_protection => true)
      put :update, @args
      response.status.should == 409
    end
        
    it "should return a 200 when successful" do
      put :update, @args
      response.status.should == 200
      response.should render_template(partial: "_the_model", count: 1)
    end

    it "should return the updated resource in the body when successful" do
      put :update, @args
      response.status.should == 200
      JSON.parse(response.body).should be_a Hash
    end

    it "should return a 422 when there are validation errors" do
      put :update, @args.merge('name' => "qz")
      response.status.should == 422
      response.content_type.should == "application/json"
      JSON.parse(response.body).should == {"name"=>["is too short (minimum is 3 characters)"]}
    end


    it "should alter the user when successful" do
      @u.name.should == @args['name']
      @u.description.should == @args['description']
      @args['name'] = "zalagadoola"
      @args['description'] = "menchikaboola"
      put :update, @args
      response.status.should == 200
      @u.reload
      @u.name.should == "zalagadoola"
      @u.description.should == "menchikaboola"
    end

  end
  
end
