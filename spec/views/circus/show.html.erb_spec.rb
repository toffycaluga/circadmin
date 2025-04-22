require 'rails_helper'

RSpec.describe "circus/show", type: :view do
  before(:each) do
    assign(:circu, Circu.create!(
      name: "Name",
      description: "MyText",
      country: "Country",
      currency: "Currency",
      active: false,
      user: nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Country/)
    expect(rendered).to match(/Currency/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(//)
  end
end
