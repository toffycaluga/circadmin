# spec/requests/stripe_webhooks_more_spec.rb
require "rails_helper"
require "ostruct"

RSpec.describe "Stripe Webhooks extra", type: :request do
  let(:user)   { create(:user, :confirmed) }
  let(:circus) { create(:circus, user:, stripe_customer_id: "cus_123") }

  before do
    CircusUser.create!(user:, circus:, role: "owner", active: true, accepted_at: Time.current)
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("STRIPE_WEBHOOK_SECRET").and_return(nil)
  end

  it "customer.subscription.updated → canceled desactiva" do
    sub = Subscription.create!(
      circus:, stripe_subscription_id: "sub_123", status: "active",
      current_period_start: Time.now, current_period_end: Time.now + 30.days,
      price_id: "price_123", active: true
    )

    updated = OpenStruct.new(
      id: "sub_123", customer: "cus_123", status: "canceled",
      current_period_start: Time.now.to_i, current_period_end: (Time.now + 30.days).to_i,
      latest_invoice: OpenStruct.new(id: "in_123", status: "paid"), items: OpenStruct.new(data: [])
    )
    allow(Stripe::Subscription).to receive(:retrieve).and_return(updated)

    payload = { type: "customer.subscription.updated", data: { object: { id: "sub_123", customer: "cus_123", status: "canceled" } } }.to_json
    post "/webhooks/stripe", params: payload, headers: { "CONTENT_TYPE" => "application/json" }
    expect(response).to have_http_status(:ok)

    sub.reload
    expect(sub.status).to eq("canceled")
    expect(sub.active).to eq(false)
  end

  it "idempotencia: misma notificación 2 veces no duplica items" do
    payload = {
      type: "checkout.session.completed",
      data: { object: { customer: "cus_123", subscription: "sub_123", metadata: { circus_id: circus.id } } }
    }.to_json

    expect {
      2.times { post "/webhooks/stripe", params: payload, headers: { "CONTENT_TYPE" => "application/json" } }
    }.to change { Subscription.count }.by(1) # solo una
  end

  it "payload inválido → 400" do
    post "/webhooks/stripe", params: "no-json", headers: { "CONTENT_TYPE" => "application/json" }
    expect(response).to have_http_status(:bad_request)
  end
end
