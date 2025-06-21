require 'rails_helper'

RSpec.describe "localities/show", type: :view do
  before(:each) do
    assign(:locality, Locality.create!(
      title: "Title",
      location: "Location",
      city: "City",
      active: false,
      notes: "MyText",
      circus: nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/Location/)
    expect(rendered).to match(/City/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(//)
  end
end
