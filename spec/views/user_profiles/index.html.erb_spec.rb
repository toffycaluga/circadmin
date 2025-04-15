require 'rails_helper'

RSpec.describe "user_profiles/index", type: :view do
  before(:each) do
    assign(:user_profiles, [
      UserProfile.create!(
        user: nil,
        nombre_completo: "Nombre Completo",
        direccion: "Direccion",
        pais: "Pais",
        tipo_moneda: "Tipo Moneda"
      ),
      UserProfile.create!(
        user: nil,
        nombre_completo: "Nombre Completo",
        direccion: "Direccion",
        pais: "Pais",
        tipo_moneda: "Tipo Moneda"
      )
    ])
  end

  it "renders a list of user_profiles" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Nombre Completo".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Direccion".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Pais".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Tipo Moneda".to_s), count: 2
  end
end
