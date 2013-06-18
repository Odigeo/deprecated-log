require "spec_helper"

describe LogExcerptsController do
  describe "routing" do

    it "routes to #show" do
      get("/v1/log_excerpts/123/456").should route_to("log_excerpts#show", from: "123", to: "456")
    end

    it "routes to #destroy" do
      delete("/v1/log_excerpts/123/456").should route_to("log_excerpts#destroy", from: "123", to: "456")
    end

  end
end
