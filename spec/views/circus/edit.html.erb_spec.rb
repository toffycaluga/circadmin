require 'rails_helper'

RSpec.describe "circus/edit", type: :view do
  let(:circu) {
    Circu.create!(
      name: "MyString",
      description: "MyText",
      country: "MyString",
      currency: "MyString",
      active: false,
      user: nil
    )
  }

  before(:each) do
    assign(:circu, circu)
  end

  it "renders the edit circu form" do
    render

    assert_select "form[action=?][method=?]", circu_path(circu), "post" do
      assert_select "input[name=?]", "circu[name]"

      assert_select "textarea[name=?]", "circu[description]"

      assert_select "input[name=?]", "circu[country]"

      assert_select "input[name=?]", "circu[currency]"

      assert_select "input[name=?]", "circu[active]"

      assert_select "input[name=?]", "circu[user_id]"
    end
  end
end
