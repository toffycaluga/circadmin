require 'rails_helper'

RSpec.describe "invitations/edit", type: :view do
  let(:invitation) {
    Invitation.create!(
      user: nil,
      circus: nil,
      sender: nil,
      message: "MyText",
      status: 1
    )
  }

  before(:each) do
    assign(:invitation, invitation)
  end

  it "renders the edit invitation form" do
    render

    assert_select "form[action=?][method=?]", invitation_path(invitation), "post" do
      assert_select "input[name=?]", "invitation[user_id]"

      assert_select "input[name=?]", "invitation[circus_id]"

      assert_select "input[name=?]", "invitation[sender_id]"

      assert_select "textarea[name=?]", "invitation[message]"

      assert_select "input[name=?]", "invitation[status]"
    end
  end
end
