require "rails_helper"

RSpec.describe CircusController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/circus").to route_to("circus#index")
    end

    it "routes to #new" do
      expect(get: "/circus/new").to route_to("circus#new")
    end

    it "routes to #show" do
      expect(get: "/circus/1").to route_to("circus#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/circus/1/edit").to route_to("circus#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/circus").to route_to("circus#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/circus/1").to route_to("circus#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/circus/1").to route_to("circus#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/circus/1").to route_to("circus#destroy", id: "1")
    end
  end
end
