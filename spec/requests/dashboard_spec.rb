require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }  # <= clave

  it "returns http success" do
    get dashboard_index_path
    expect(response).to have_http_status(:success)
  end
end
