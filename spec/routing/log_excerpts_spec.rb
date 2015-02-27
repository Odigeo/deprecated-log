require "spec_helper"

describe LogExcerptsController do
  describe "routing" do

    it "routes to #show" do
      expect(get("/v1/log_excerpts/123/456")).to route_to("log_excerpts#show", from: "123", to: "456")
    end

    it "routes to #destroy" do
      expect(delete("/v1/log_excerpts/123/456")).to route_to("log_excerpts#destroy", from: "123", to: "456")
    end

    it "routes to #create" do
      expect(post("/v1/log_excerpts")).to route_to("log_excerpts#create")
    end

    it "does not route to #update" do
      expect(put("/v1/log_excerpts")).not_to be_routable
    end
    
  end
end
