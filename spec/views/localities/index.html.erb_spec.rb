require 'rails_helper'

RSpec.describe "localities/index", type: :view do
  before(:each) do
    assign(:localities, [
      Locality.create!(
        title: "Title",
        location: "Location",
        city: "City",
        active: false,
        notes: "MyText",
        circus: nil
      ),
      Locality.create!(
        title: "Title",
        location: "Location",
        city: "City",
        active: false,
        notes: "MyText",
        circus: nil
      )
    ])
  end

  it "renders a list of localities" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Title".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Location".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("City".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(false.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
  end
end
