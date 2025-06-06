require 'rails_helper'

RSpec.describe "CustomInvitations", type: :request do
  describe "GET /create" do
    it "returns http success" do
      get "/custom_invitations/create"
      expect(response).to have_http_status(:success)
    end
  end

end
