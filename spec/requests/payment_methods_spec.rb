# spec/requests/payment_methods_spec.rb
require "rails_helper"
require "ostruct"

RSpec.describe "PaymentMethods", type: :request do
  let(:password) { "Password1!" }
  let(:user)     { create(:user, :confirmed, password: password, password_confirmation: password) }
  let(:circus)   { create(:circus, user: user, stripe_customer_id: "cus_123") }

  # Si tu app necesita perfil para no redirigir, crea uno mínimo
  def ensure_user_profile!(user)
    if defined?(UserProfile) && user.respond_to?(:user_profile) && user.user_profile.blank?
      attrs = {}
      attrs[:full_name]    = "Usuario Prueba" if UserProfile.column_names.include?("full_name")
      attrs[:name]         = "Usuario Prueba" if UserProfile.column_names.include?("name")
      attrs[:country]      = "CL"             if UserProfile.column_names.include?("country")
      attrs[:pais]         = "CL"             if UserProfile.column_names.include?("pais")
      attrs[:currency]     = "CLP"            if UserProfile.column_names.include?("currency")
      attrs[:tipo_moneda]  = "CLP"            if UserProfile.column_names.include?("tipo_moneda")
      UserProfile.create!(attrs.merge(user: user)) if attrs.any?
    end
  end

  before do
    # Owner/miembro activo aceptado (por si tu controller filtra por membership)
    if defined?(CircusUser)
      CircusUser.find_or_create_by!(
        user:        user,
        circus:      circus,
        role:        "owner",
        active:      true,
        accepted_at: Time.current
      )
    end

    # Login real
    post user_session_path, params: { user: { email: user.email, password: password } }
    follow_redirect! if response.redirect?

    # Perfil mínimo para evitar redirecciones del filtro
    ensure_user_profile!(user)
  end

  describe "GET /circuses/:circus_id/payment_methods" do
    it "ok" do
      get circus_payment_methods_path(circus)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /circuses/:circus_id/payment_methods/new" do
    it "ok (con SetupIntent stub)" do
      allow(Stripe::SetupIntent).to receive(:create)
        .with(customer: circus.stripe_customer_id)
        .and_return(OpenStruct.new(id: "seti_123"))

      get new_circus_payment_method_path(circus)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /circuses/:circus_id/payment_methods" do
    it "attacha PM en Stripe, lo deja por defecto y redirige al index" do
      allow(Stripe::PaymentMethod).to receive(:attach)
        .with("pm_123", { customer: "cus_123" }).and_return(true)
      allow(Stripe::Customer).to receive(:update)
        .with("cus_123", invoice_settings: { default_payment_method: "pm_123" }).and_return(true)

      expect {
        post circus_payment_methods_path(circus), params: {
          payment_method_id: "pm_123",
          card_brand: "visa",
          last4: "4242",
          exp_month: 12,
          exp_year: 2030
        }
      }.to change { circus.payment_methods.count }.by(1)

      expect(response).to redirect_to(circus_payment_methods_path(circus))
      follow_redirect!
      expect(response).to have_http_status(:ok)

      pm = circus.payment_methods.order(:id).last
      expect(pm).to have_attributes(
        stripe_payment_method_id: "pm_123",
        card_brand: "visa",
        last4: "4242",
        exp_month: 12,
        exp_year: 2030,
        default: true
      )
    end
  end

  describe "DELETE /circuses/:circus_id/payment_methods/:id" do
    it "desatacha en Stripe y elimina el registro en DB" do
      pm = circus.payment_methods.create!(
        stripe_payment_method_id: "pm_abc",
        card_brand: "visa",
        last4: "4242",
        exp_month: 12,
        exp_year: 2030,
        default: true
      )

      allow(Stripe::PaymentMethod).to receive(:detach)
        .with("pm_abc").and_return(true)

      expect {
        delete circus_payment_method_path(circus, pm)
      }.to change { circus.payment_methods.count }.by(-1)

      expect(response).to redirect_to(circus_payment_methods_path(circus))
      expect { pm.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
