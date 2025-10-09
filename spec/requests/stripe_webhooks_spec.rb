# spec/requests/stripe_webhooks_spec.rb
require "rails_helper"

RSpec.describe "Stripe Webhooks", type: :request do
  let(:user)   { create(:user, :confirmed) }
  let(:circus) { create(:circus, user: user, stripe_customer_id: "cus_123") }

  before do
    # membership owner
    CircusUser.create!(user: user, circus: circus, role: "owner", active: true, accepted_at: Time.current)

    # 👇 MUY IMPORTANTE: desactiva verificación de firma en tests
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("STRIPE_WEBHOOK_SECRET").and_return(nil)
  end

  it "procesa checkout.session.completed y upserta subscription" do
    payload = {
      type: "checkout.session.completed",
      data: { object: { customer: "cus_123", subscription: "sub_123", metadata: { circus_id: circus.id } } }
    }.to_json

    post "/webhooks/stripe", params: payload, headers: { "CONTENT_TYPE" => "application/json" }
    expect(response).to have_http_status(:ok)
    expect(Subscription.find_by(stripe_subscription_id: "sub_123")).to be_present
  end

  it "marca past_due en invoice.payment_failed" do
    Subscription.create!(
      circus: circus,
      stripe_subscription_id: "sub_123",
      status: "active",
      current_period_start: Time.now,
      current_period_end: Time.now + 30.days,
      price_id: "price_123",
      active: true
    )

    payload = {
      type: "invoice.payment_failed",
      data: { object: { customer: "cus_123", id: "in_failed_1", status: "open", subscription: "sub_123" } }
    }.to_json

    post "/webhooks/stripe", params: payload, headers: { "CONTENT_TYPE" => "application/json" }
    expect(response).to have_http_status(:ok)

    sub = Subscription.find_by(stripe_subscription_id: "sub_123")
    expect(sub.status).to eq("past_due")
    expect(sub.active).to eq(false)
    expect(sub.latest_invoice_id).to eq("in_failed_1")
  end
end
