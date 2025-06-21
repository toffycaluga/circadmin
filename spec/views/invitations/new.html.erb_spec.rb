require 'rails_helper'

RSpec.describe "invitations/new", type: :view do
  before(:each) do
    assign(:invitation, Invitation.new(
      user: nil,
      circus: nil,
      sender: nil,
      message: "MyText",
      status: 1
    ))
  end

  it "renders new invitation form" do
    render

    assert_select "form[action=?][method=?]", invitations_path, "post" do
      assert_select "input[name=?]", "invitation[user_id]"

      assert_select "input[name=?]", "invitation[circus_id]"

      assert_select "input[name=?]", "invitation[sender_id]"

      assert_select "textarea[name=?]", "invitation[message]"

      assert_select "input[name=?]", "invitation[status]"
    end
  end
end
