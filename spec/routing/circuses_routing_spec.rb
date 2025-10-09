require "rails_helper"

RSpec.describe CircusesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/circuses").to route_to("circuses#index")
    end

    it "routes to #new" do
      expect(get: "/circuses/new").to route_to("circuses#new")
    end

    it "routes to #show" do
      expect(get: "/circuses/1").to route_to("circuses#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/circuses/1/edit").to route_to("circuses#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/circuses").to route_to("circuses#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/circuses/1").to route_to("circuses#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/circuses/1").to route_to("circuses#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/circuses/1").to route_to("circuses#destroy", id: "1")
    end
  end
end
