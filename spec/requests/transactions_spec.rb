# spec/requests/subscriptions_check_availability_spec.rb
require "rails_helper"

RSpec.describe "Subscriptions#check_availability", type: :request do
  let(:password) { "Password!123" }
  let(:user)     { create(:user, :confirmed, password:, password_confirmation: password) }
  let(:circus)   { create(:circus, user:, stripe_customer_id: "cus_123") }

  before do
    post user_session_path, params: { user: { email: user.email, password: } }
    CircusUser.create!(user:, circus:, role: "owner", active: true, accepted_at: Time.current)
  end

  def get_json
    get circus_subscription_check_availability_path(circus), as: :json
    JSON.parse(response.body)
  end

  it "allowed:false cuando no hay suscripción activa" do
    body = get_json
    expect(response).to have_http_status(:ok)
    expect(body["allowed"]).to eq(false)
  end

  it "allowed:true con sub activa + item core activo" do
    sub = Subscription.create!(
      circus:, stripe_subscription_id: "sub_1", status: "active",
      current_period_start: Time.now, current_period_end: Time.now + 30.days,
      price_id: "price_123", active: true
    )
    SubscriptionItem.create!(
      subscription: sub, stripe_subscription_item_id: "si_1",
      price_id: "price_123", service_key: "core", quantity: 1, active: true
    )
    body = get_json
    expect(body["allowed"]).to eq(true)
  end

  it "allowed:false si falta item requerido" do
    Subscription.create!(
      circus:, stripe_subscription_id: "sub_2", status: "active",
      current_period_start: Time.now, current_period_end: Time.now + 30.days,
      price_id: "price_456", active: true
    )
    body = get_json
    expect(body["allowed"]).to eq(false)
  end
end
