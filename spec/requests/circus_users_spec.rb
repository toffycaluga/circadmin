require "rails_helper"

RSpec.describe "CircusUsers", type: :request do
  let(:password) { "Password!123" }
  let(:owner)    { create(:user, :confirmed, password:, password_confirmation: password) }
  let(:circus)   { create(:circus, user: owner) }
  let!(:cu)      { CircusUser.create!(user: owner, circus:, role: "owner", active: true, accepted_at: Time.current) }

  before do
    post user_session_path, params: { user: { email: owner.email, password: } }
  end

  it "GET /circus_users/:id/edit ok" do
    get edit_circus_user_path(cu)
    expect(response).to have_http_status(:ok)
  end

  it "PATCH /circus_users/:id actualiza ok" do
    patch circus_user_path(cu), params: { circus_user: { role: "owner" } }
    expect(response).to have_http_status(:found) # si redirige
  end

  it "PATCH /circus_users/:id/deactivate desactiva" do
    patch deactivate_circus_user_path(cu)
    expect(response).to have_http_status(:found)
  end
end
