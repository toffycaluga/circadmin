require 'rails_helper'

RSpec.describe "transactions/new", type: :view do
  before(:each) do
    assign(:transaction, Transaction.new(
      title: "MyString",
      amount: "9.99",
      transaction_type: "MyString",
      description: "MyText",
      user: nil,
      circus: nil
    ))
  end

  it "renders new transaction form" do
    render

    assert_select "form[action=?][method=?]", transactions_path, "post" do

      assert_select "input[name=?]", "transaction[title]"

      assert_select "input[name=?]", "transaction[amount]"

      assert_select "input[name=?]", "transaction[transaction_type]"

      assert_select "textarea[name=?]", "transaction[description]"

      assert_select "input[name=?]", "transaction[user_id]"

      assert_select "input[name=?]", "transaction[circus_id]"
    end
  end
end
