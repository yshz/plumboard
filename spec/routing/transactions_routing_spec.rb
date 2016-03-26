require "spec_helper"

describe TransactionsController do
  describe "routing" do

    it "routes to #index" do
      expect(get("/transactions")).to route_to("transactions#index")
    end

    it "routes to #show" do
      expect(get("/transactions/1")).to route_to("transactions#show", :id => "1")
    end

    it "does not route to #edit" do
      expect(get("/transactions/1/edit")).not_to route_to("transactions#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/transactions")).to route_to("transactions#create")
    end

    it "does not route to #update" do
      expect(put("/transactions/1")).not_to route_to("transactions#update", :id => "1")
    end

    it "does not route to #destroy" do
      expect(delete("/transactions/1")).not_to route_to("transactions#destroy", :id => "1")
    end

    it "routes to #new" do
      expect(get("/transactions/new")).to route_to("transactions#new")
    end

    it "routes to #refund" do
      expect(get("/transactions/1/refund")).to route_to("transactions#refund", :id => "1")
    end
  end
end


