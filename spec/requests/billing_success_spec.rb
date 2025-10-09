require "rails_helper"

RSpec.describe "Billing success", type: :request do
  let(:user) { create(:user) }
  let(:circus) { create(:circus, user: user) }
  let!(:cu) { create(:circus_user, user: user, circus: circus, role: "owner", active: true, accepted_at: Time.current) }

  before do
    sign_in user
    allow(Stripe::Checkout::Session).to receive(:retrieve).and_wrap_original do |_m, id:, expand:|
      expect(id).to eq("cs_test_abc")
      expect(expand).to include("subscription.items.data.price")
      fake_checkout_session(
        id: "cs_test_abc",
        subscription: fake_stripe_subscription(
          id: "sub_test_abc",
          status: "trialing",
          items: [ fake_stripe_item(price: fake_stripe_price(id: "price_test_123", metadata: { "service_key" => "core" })) ]
        ),
        payment_status: "paid",
        customer: "cus_test_abc"
      )
    end
  end

  it "upserta subscription + items y redirige al dashboard" do
    get billing_success_path(session_id: "cs_test_abc", circus_id: circus.id)

    expect(response).to redirect_to(dashboard_index_path)

    sub = circus.subscriptions.find_by(stripe_subscription_id: "sub_test_abc")
    expect(sub).to be_present
    expect(sub.active).to be_truthy
    expect(sub.status).to eq("trialing")
    expect(sub.stripe_customer_id).to eq("cus_test_abc")
    expect(sub.price_id).to eq("price_test_123")

    item = sub.subscription_items.find_by(service_key: "core")
    expect(item).to be_present
    expect(item.active).to be_truthy
    expect(item.price_id).to eq("price_test_123")
  end
end
