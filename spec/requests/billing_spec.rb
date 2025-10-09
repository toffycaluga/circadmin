require "rails_helper"

RSpec.describe "Billings", type: :request do
  let(:password) { "Password!123" }
  let(:user)     { create(:user, :confirmed, password:, password_confirmation: password) }
  let(:circus)   { create(:circus, user:, stripe_customer_id: "cus_123") }

  before do
    post user_session_path, params: { user: { email: user.email, password: } }
    CircusUser.create!(user:, circus:, role: "owner", active: true, accepted_at: Time.current)
  end

  it "POST /billing/checkout redirige a checkout" do
    session = double("CheckoutSession", url: "https://checkout.stripe.test/sess_123")
    allow(Stripe::Checkout::Session).to receive(:create).and_return(session)

    post billing_checkout_path, params: { circus_id: circus.id }  # <— POST y helper
    expect(response).to have_http_status(:found)
    expect(response.location).to include("checkout.stripe.test")
  end

  it "GET /billing/success redirige al dashboard" do
    get billing_success_path
    expect(response).to have_http_status(:found)
    expect(response).to redirect_to(dashboard_index_path)
  end

  it "GET /billing/cancel redirige al dashboard" do
    get billing_cancel_path
    expect(response).to have_http_status(:found)
    expect(response).to redirect_to(dashboard_index_path)
  end

  it "GET /billing/portal redirige al portal" do
    portal = double("PortalSession", url: "https://billing.stripe.test/portal_123")
    allow(Stripe::BillingPortal::Session).to receive(:create).and_return(portal)

    get billing_portal_path, params: { circus_id: circus.id }
    expect(response).to have_http_status(:found)
    expect(response.location).to include("billing.stripe.test")
  end
end
