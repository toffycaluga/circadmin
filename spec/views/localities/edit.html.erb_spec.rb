require 'rails_helper'

RSpec.describe "localities/edit", type: :view do
  let(:locality) {
    Locality.create!(
      title: "MyString",
      location: "MyString",
      city: "MyString",
      active: false,
      notes: "MyText",
      circus: nil
    )
  }

  before(:each) do
    assign(:locality, locality)
  end

  it "renders the edit locality form" do
    render

    assert_select "form[action=?][method=?]", locality_path(locality), "post" do
      assert_select "input[name=?]", "locality[title]"

      assert_select "input[name=?]", "locality[location]"

      assert_select "input[name=?]", "locality[city]"

      assert_select "input[name=?]", "locality[active]"

      assert_select "textarea[name=?]", "locality[notes]"

      assert_select "input[name=?]", "locality[circus_id]"
    end
  end
end
