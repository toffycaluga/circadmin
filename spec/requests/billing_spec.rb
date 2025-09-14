require 'rails_helper'

RSpec.describe "Billings", type: :request do
  describe "GET /create_checkout_session" do
    it "returns http success" do
      get "/billing/create_checkout_session"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /success" do
    it "returns http success" do
      get "/billing/success"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /cancel" do
    it "returns http success" do
      get "/billing/cancel"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /portal" do
    it "returns http success" do
      get "/billing/portal"
      expect(response).to have_http_status(:success)
    end
  end

end
