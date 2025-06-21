require 'rails_helper'

RSpec.describe "transactions/edit", type: :view do
  let(:transaction) {
    Transaction.create!(
      title: "MyString",
      amount: "9.99",
      transaction_type: "MyString",
      description: "MyText",
      user: nil,
      circus: nil
    )
  }

  before(:each) do
    assign(:transaction, transaction)
  end

  it "renders the edit transaction form" do
    render

    assert_select "form[action=?][method=?]", transaction_path(transaction), "post" do
      assert_select "input[name=?]", "transaction[title]"

      assert_select "input[name=?]", "transaction[amount]"

      assert_select "input[name=?]", "transaction[transaction_type]"

      assert_select "textarea[name=?]", "transaction[description]"

      assert_select "input[name=?]", "transaction[user_id]"

      assert_select "input[name=?]", "transaction[circus_id]"
    end
  end
end
