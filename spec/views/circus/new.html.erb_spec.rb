require 'rails_helper'

RSpec.describe "circus/new", type: :view do
  before(:each) do
    assign(:circu, Circu.new(
      name: "MyString",
      description: "MyText",
      country: "MyString",
      currency: "MyString",
      active: false,
      user: nil
    ))
  end

  it "renders new circu form" do
    render

    assert_select "form[action=?][method=?]", circus_path, "post" do

      assert_select "input[name=?]", "circu[name]"

      assert_select "textarea[name=?]", "circu[description]"

      assert_select "input[name=?]", "circu[country]"

      assert_select "input[name=?]", "circu[currency]"

      assert_select "input[name=?]", "circu[active]"

      assert_select "input[name=?]", "circu[user_id]"
    end
  end
end
