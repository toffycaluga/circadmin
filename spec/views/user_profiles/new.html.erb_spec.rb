require 'rails_helper'

RSpec.describe "user_profiles/new", type: :view do
  before(:each) do
    assign(:user_profile, UserProfile.new(
      user: nil,
      nombre_completo: "MyString",
      direccion: "MyString",
      pais: "MyString",
      tipo_moneda: "MyString"
    ))
  end

  it "renders new user_profile form" do
    render

    assert_select "form[action=?][method=?]", user_profiles_path, "post" do

      assert_select "input[name=?]", "user_profile[user_id]"

      assert_select "input[name=?]", "user_profile[nombre_completo]"

      assert_select "input[name=?]", "user_profile[direccion]"

      assert_select "input[name=?]", "user_profile[pais]"

      assert_select "input[name=?]", "user_profile[tipo_moneda]"
    end
  end
end
