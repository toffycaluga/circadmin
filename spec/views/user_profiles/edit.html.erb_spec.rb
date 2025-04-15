require 'rails_helper'

RSpec.describe "user_profiles/edit", type: :view do
  let(:user_profile) {
    UserProfile.create!(
      user: nil,
      nombre_completo: "MyString",
      direccion: "MyString",
      pais: "MyString",
      tipo_moneda: "MyString"
    )
  }

  before(:each) do
    assign(:user_profile, user_profile)
  end

  it "renders the edit user_profile form" do
    render

    assert_select "form[action=?][method=?]", user_profile_path(user_profile), "post" do

      assert_select "input[name=?]", "user_profile[user_id]"

      assert_select "input[name=?]", "user_profile[nombre_completo]"

      assert_select "input[name=?]", "user_profile[direccion]"

      assert_select "input[name=?]", "user_profile[pais]"

      assert_select "input[name=?]", "user_profile[tipo_moneda]"
    end
  end
end
