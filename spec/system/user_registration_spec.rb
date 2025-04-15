require 'rails_helper'

RSpec.describe 'Registro de usuarios', type: :system do
  it 'permite a un visitante registrarse' do
    visit new_user_registration_path

    fill_in 'Email', with: 'toffy@example.com'
    fill_in 'Password', with: 'segura123'
    fill_in 'Password confirmation', with: 'segura123'
    click_button 'Sign up'

    expect(page).to have_content('Bienvenido') # O el texto que aparezca post-login
  end
end
