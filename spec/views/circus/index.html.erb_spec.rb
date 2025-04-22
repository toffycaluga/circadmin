require 'rails_helper'

RSpec.describe "circus/index", type: :view do
  before(:each) do
    assign(:circus, [
      Circu.create!(
        name: "Name",
        description: "MyText",
        country: "Country",
        currency: "Currency",
        active: false,
        user: nil
      ),
      Circu.create!(
        name: "Name",
        description: "MyText",
        country: "Country",
        currency: "Currency",
        active: false,
        user: nil
      )
    ])
  end

  it "renders a list of circus" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Country".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Currency".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(false.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
  end
end
