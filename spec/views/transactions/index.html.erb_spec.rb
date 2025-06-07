require 'rails_helper'

RSpec.describe "transactions/index", type: :view do
  before(:each) do
    assign(:transactions, [
      Transaction.create!(
        title: "Title",
        amount: "9.99",
        transaction_type: "Transaction Type",
        description: "MyText",
        user: nil,
        circus: nil
      ),
      Transaction.create!(
        title: "Title",
        amount: "9.99",
        transaction_type: "Transaction Type",
        description: "MyText",
        user: nil,
        circus: nil
      )
    ])
  end

  it "renders a list of transactions" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Title".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("9.99".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Transaction Type".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
  end
end
