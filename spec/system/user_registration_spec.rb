require 'rails_helper'

RSpec.describe "Autenticación de usuarios", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "permite que un usuario se registre" do
    visit new_user_registration_path

    fill_in "Correo electrónico", with: "nuevo@circo.com"
    fill_in "Contraseña", with: "123456"
    fill_in "Confirmación de la contraseña", with: "123456"

    click_button "Registrarse"

    expect(page).to have_content("Bienvenido")
  end

  it "permite iniciar sesión" do
    User.create!(email: "test@circo.com", password: "123456")

    visit new_user_session_path

    fill_in "Correo electrónico", with: "test@circo.com"
    fill_in "Contraseña", with: "123456"
    click_button "Iniciar sesión"

    expect(page).to have_content("Ha iniciado sesión satisfactoriamente.")
  end

  it "permite cerrar sesión" do
    user = User.create!(email: "logout@circo.com", password: "123456")

    visit new_user_session_path
    fill_in "Correo electrónico", with: "logout@circo.com"
    fill_in "Contraseña", with: "123456"
    click_button "Iniciar sesión"

    # Asegurar que el login fue exitoso
    expect(page).to have_content("logout@circo.com")

    # Clic en enlace para cerrar sesión
    click_button "Cerrar sesión"

    # Asegurar que redirige correctamente y ya no se muestra el email
    expect(page).to have_content("Iniciar sesión") # o lo que se muestre en la pantalla de logout
    expect(page).not_to have_content("logout@circo.com")
  end


  # it "no permite registrarse sin email ni contraseña" do
  #   visit new_user_registration_path

  #   click_button "Registrarse"

  #   expect(page).to have_content("no puede estar en blanco") # o el mensaje que uses
  # end

  it "no permite iniciar sesión con contraseña incorrecta" do
    User.create!(email: "fallo@circo.com", password: "123456")

    visit new_user_session_path
    fill_in "Correo electrónico", with: "fallo@circo.com"
    fill_in "Contraseña", with: "incorrecta"
    click_button "Iniciar sesión"

    expect(page).to have_content("Correo o contraseña inválidos.") # o el mensaje real que uses
  end
  # it "permite acceso a /dashboard solo si está logueado" do
  #   user = User.create!(email: "acceso@circo.com", password: "123456")

  #   visit dashboard_path
  #   expect(current_path).to eq(new_user_session_path)

  #   # Ahora iniciamos sesión
  #   visit new_user_session_path
  #   fill_in "Correo electrónico", with: "acceso@circo.com"
  #   fill_in "Contraseña", with: "123456"
  #   click_button "Iniciar sesión"

  #   visit dashboard_path
  #   expect(page).to have_content("Dashboard") # o lo que se muestre ahí
  # end

  # it "muestra los datos personales del usuario" do
  #   user = User.create!(email: "datos@circo.com", password: "123456")
  #   user.create_dato_personal!(
  #     nombre_completo: "Toffy Caluga",
  #     dirección: "Carpa 123",
  #     país: "Chile",
  #     tipo_moneda: "CLP"
  #   )

  #   visit new_user_session_path
  #   fill_in "Correo electrónico", with: "datos@circo.com"
  #   fill_in "Contraseña", with: "123456"
  #   click_button "Iniciar sesión"

  #   visit user_path(user)
  #   expect(page).to have_content("Toffy Caluga")
  #   expect(page).to have_content("Carpa 123")
  # end
end
