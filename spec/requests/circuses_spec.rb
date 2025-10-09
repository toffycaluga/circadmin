# spec/requests/circuses_spec.rb
require "rails_helper"

RSpec.describe "/circuses", type: :request do
  # Usuario con password conocida para login HTTP real
  let(:user_password) { "Password!123" }
  # Usa el trait :confirmed si existe; si no existe, el before de abajo confirmará al user igualmente.
  let(:user) { create(:user, :confirmed, password: user_password, password_confirmation: user_password) }

  # -----------------------------------
  # Helpers
  # -----------------------------------
  def ensure_user_profile!(user)
    # Si tu app redirige cuando falta perfil, crea uno mínimo.
    begin
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
    rescue StandardError => e
      Rails.logger.warn "No se pudo crear UserProfile de prueba: #{e.message}"
    end
  end

  def create_owned_circus!(user, attrs = {})
    defaults = {
      name:        "Circo de Prueba",
      description: "Descripción de prueba",
      country:     "CL",
      currency:    "CLP",
      active:      true,
      user:        user
    }
    circus = Circus.create!(defaults.merge(attrs))

    # Asociación owner activa y aceptada para que pase set_circus (current_user.circuses.find)
    if defined?(CircusUser)
      CircusUser.find_or_create_by!(
        user:        user,
        circus:      circus,
        role:        "owner",
        active:      true,
        accepted_at: Time.current
      )
    end

    circus
  end

  # -----------------------------------
  # Login HTTP real antes de cada test
  # -----------------------------------
  before do
    # Si tu User es confirmable pero tu factory no aplica :confirmed, esto lo asegura.
    user.confirm if user.respond_to?(:confirm) && user.respond_to?(:confirmed?) && !user.confirmed?

    # 1) Login vía Devise como si fuera el navegador
    post user_session_path, params: { user: { email: user.email, password: user_password } }
    follow_redirect! if response.redirect?
    # 2) Perfil mínimo (si tu layout lo requiere)
    ensure_user_profile!(user)
  end

  # -----------------------------------
  # Datos base
  # -----------------------------------
  let(:valid_attributes) do
    {
      name:        "Mi Circo",
      description: "Un circo increíble",
      country:     "CL",
      currency:    "CLP",
      active:      true
    }
  end

  let(:invalid_attributes) do
    skip("Define validaciones en Circus y actualiza este hash (por ejemplo: { name: '' })")
  end

  # -----------------------------------
  # TESTS
  # -----------------------------------

  describe "GET /index" do
    it "renders a successful response" do
      create_owned_circus!(user)
      get circuses_url
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      circus = create_owned_circus!(user)
      get circus_url(circus)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_circus_url
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      circus = create_owned_circus!(user)
      get edit_circus_url(circus)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Circus" do
        expect {
          post circuses_url, params: { circus: valid_attributes }
        }.to change(Circus, :count).by(1)
      end

      it "redirects to root (según tu controlador actual)" do
        post circuses_url, params: { circus: valid_attributes }
        expect(response).to redirect_to(root_path)
      end
    end

    context "with invalid parameters" do
      it "does not create a new Circus" do
        skip("Activa cuando definas validaciones en Circus")
        expect {
          post circuses_url, params: { circus: invalid_attributes }
        }.not_to change(Circus, :count)
      end

      it "renders 422 (new)" do
        skip("Activa cuando definas validaciones en Circus")
        post circuses_url, params: { circus: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) { { name: "Nuevo Nombre" } }

      it "updates the requested circus" do
        circus = create_owned_circus!(user)
        patch circus_url(circus), params: { circus: new_attributes }
        circus.reload
        expect(circus.name).to eq("Nuevo Nombre")
      end

      it "redirects to the circus" do
        circus = create_owned_circus!(user)
        patch circus_url(circus), params: { circus: new_attributes }
        expect(response).to redirect_to(circus_url(circus))
      end
    end

    context "with invalid parameters" do
      it "renders 422 (edit)" do
        skip("Activa cuando definas validaciones en Circus")
        circus = create_owned_circus!(user)
        patch circus_url(circus), params: { circus: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested circus" do
      circus = create_owned_circus!(user)
      expect {
        delete circus_url(circus)
      }.to change(Circus, :count).by(-1)
    end

    it "redirects to the circuses list" do
      circus = create_owned_circus!(user)
      delete circus_url(circus)
      expect(response).to redirect_to(circuses_url)
    end
  end
end
