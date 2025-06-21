require 'rails_helper'

RSpec.describe "transactions/show", type: :view do
  before(:each) do
    assign(:transaction, Transaction.create!(
      title: "Title",
      amount: "9.99",
      transaction_type: "Transaction Type",
      description: "MyText",
      user: nil,
      circus: nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/Transaction Type/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
