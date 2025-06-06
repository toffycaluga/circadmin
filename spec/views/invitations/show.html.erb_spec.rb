require 'rails_helper'

RSpec.describe "invitations/show", type: :view do
  before(:each) do
    assign(:invitation, Invitation.create!(
      user: nil,
      circus: nil,
      sender: nil,
      message: "MyText",
      status: 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/2/)
  end
end
