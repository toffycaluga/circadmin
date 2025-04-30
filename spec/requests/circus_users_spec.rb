require 'rails_helper'

RSpec.describe "CircusUsers", type: :request do
  describe "GET /edit" do
    it "returns http success" do
      get "/circus_users/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/circus_users/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/circus_users/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end
