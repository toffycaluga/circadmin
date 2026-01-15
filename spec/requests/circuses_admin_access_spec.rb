# spec/requests/circuses_admin_access_spec.rb
require "rails_helper"

RSpec.describe "Admin de Circo", type: :request do
  let(:password) { "Password!123" }
  let(:owner)    { create(:user, :confirmed, password:, password_confirmation: password) }
  let(:guest)    { create(:user, :confirmed, password:, password_confirmation: password) }
  let(:circus)   { create(:circus, user: owner) }

  before do
    CircusUser.create!(user: owner, circus:, role: "owner", active: true, accepted_at: Time.current)
  end

  it "owner puede ver /admin" do
    post user_session_path, params: { user: { email: owner.email, password: } }
    get admin_circus_path(circus)
    expect(response).to have_http_status(:ok)
  end

  it "invitado sin relación/aceptación NO puede ver /admin" do
    post user_session_path, params: { user: { email: guest.email, password: } }
    get admin_circus_path(circus)
    expect(response).to have_http_status(:found)
  end
end
