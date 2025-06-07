require 'rails_helper'

RSpec.describe "localities/new", type: :view do
  before(:each) do
    assign(:locality, Locality.new(
      title: "MyString",
      location: "MyString",
      city: "MyString",
      active: false,
      notes: "MyText",
      circus: nil
    ))
  end

  it "renders new locality form" do
    render

    assert_select "form[action=?][method=?]", localities_path, "post" do

      assert_select "input[name=?]", "locality[title]"

      assert_select "input[name=?]", "locality[location]"

      assert_select "input[name=?]", "locality[city]"

      assert_select "input[name=?]", "locality[active]"

      assert_select "textarea[name=?]", "locality[notes]"

      assert_select "input[name=?]", "locality[circus_id]"
    end
  end
end
