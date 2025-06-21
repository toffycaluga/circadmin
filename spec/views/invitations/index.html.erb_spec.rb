require 'rails_helper'

RSpec.describe "invitations/index", type: :view do
  before(:each) do
    assign(:invitations, [
      Invitation.create!(
        user: nil,
        circus: nil,
        sender: nil,
        message: "MyText",
        status: 2
      ),
      Invitation.create!(
        user: nil,
        circus: nil,
        sender: nil,
        message: "MyText",
        status: 2
      )
    ])
  end

  it "renders a list of invitations" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(2.to_s), count: 2
  end
end
