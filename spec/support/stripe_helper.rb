module StripeHelpers
  def fake_stripe_price(id: "price_test_123", product_id: "prod_test_123", metadata: { "service_key" => "core" })
    OpenStruct.new(
      id: id,
      product: product_id,
      metadata: metadata,
      unit_amount: 2000,
      currency: "eur",
      recurring: OpenStruct.new(interval: "month", interval_count: 1)
    )
  end

  def fake_stripe_item(id: "si_test_123", price: fake_stripe_price)
    OpenStruct.new(
      id: id,
      price: price,
      quantity: 1
    )
  end

  def fake_stripe_subscription(id: "sub_test_123", status: "trialing", items: [ fake_stripe_item ], current_period_start: Time.now.to_i, current_period_end: 30.days.from_now.to_i, cancel_at_period_end: false, customer: "cus_test_123")
    OpenStruct.new(
      id: id,
      status: status,
      items: OpenStruct.new(data: items),
      current_period_start: current_period_start,
      current_period_end: current_period_end,
      cancel_at_period_end: cancel_at_period_end,
      customer: customer,
      latest_invoice: OpenStruct.new(id: "in_test_123", status: "paid")
    )
  end

  def fake_checkout_session(id: "cs_test_123", subscription: fake_stripe_subscription, payment_status: "paid", customer: "cus_test_123")
    OpenStruct.new(
      id: id,
      subscription: subscription,
      payment_status: payment_status,
      customer: customer
    )
  end

  def fake_webhook_event(type:, object:)
    OpenStruct.new(
      type: type,
      data: OpenStruct.new(object: object)
    )
  end
end

RSpec.configure do |config|
  config.include StripeHelpers
end
