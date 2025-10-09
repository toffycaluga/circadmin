# spec/requests/_smoke_auth_spec.rb
require 'rails_helper'
RSpec.describe "Smoke auth", type: :request do
  it "keeps the session with login_as" do
    user = create(:user)
    login_as user, scope: :user
    get dashboard_index_path
    expect(response.status).to be_between(200, 399).inclusive
  end
end
