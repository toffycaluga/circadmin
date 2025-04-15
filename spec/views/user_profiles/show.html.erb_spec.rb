require 'rails_helper'

RSpec.describe "user_profiles/show", type: :view do
  before(:each) do
    assign(:user_profile, UserProfile.create!(
      user: nil,
      nombre_completo: "Nombre Completo",
      direccion: "Direccion",
      pais: "Pais",
      tipo_moneda: "Tipo Moneda"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Nombre Completo/)
    expect(rendered).to match(/Direccion/)
    expect(rendered).to match(/Pais/)
    expect(rendered).to match(/Tipo Moneda/)
  end
end
