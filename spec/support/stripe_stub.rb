require "ostruct"

RSpec.configure do |config|
  config.before(:each) do
    # Cuando el controlador hace Stripe::Subscription.retrieve(...)
    item = OpenStruct.new(
      id: "si_1",
      price: OpenStruct.new(
        id: "price_123",
        product: "prod_123",
        unit_amount: 1000,
        currency: "clp",
        recurring: OpenStruct.new(interval: "month", interval_count: 1),
        metadata: { "service_key" => "core" }
      ),
      quantity: 1
    )

    sub = OpenStruct.new(
      id: "sub_123",
      customer: "cus_123",
      status: "active",
      current_period_start: Time.now.to_i,
      current_period_end:   (Time.now + 30.days).to_i,
      latest_invoice: OpenStruct.new(id: "in_123", status: "paid"),
      items: OpenStruct.new(data: [ item ])
    )

    allow(Stripe::Subscription).to receive(:retrieve).and_return(sub)
  end
end
