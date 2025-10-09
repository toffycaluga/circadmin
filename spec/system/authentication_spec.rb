# spec/system/authentication_spec.rb
require "rails_helper"

RSpec.describe "Autenticación", type: :system do
  let(:password) { "Password!123" }

  it "permite registrarse e iniciar sesión" do
    driven_by(:rack_test)
    visit new_user_registration_path
    fill_in "Email", with: "nuevo@circo.com"
    fill_in "Password", with: password
    fill_in "Password confirmation", with: password
    click_button "Sign up"

    # En confirmable, tras registrarse queda pendiente de confirmación:
    expect(page).to have_content("A message with a confirmation link")

    # Simula confirmación
    user = User.find_by(email: "nuevo@circo.com")
    user.confirm

    visit new_user_session_path
    fill_in "Email", with: "nuevo@circo.com"
    fill_in "Password", with: password
    click_button "Log in"
    expect(page).to have_content("Signed in successfully")
  end
end
