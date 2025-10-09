# app/services/stripe_customer_sync.rb
class StripeCustomerSync
  def self.ensure_customer!(circus)
    return circus.stripe_customer_id if circus.stripe_customer_id.present?

    customer = Stripe::Customer.create({
      name: circus.name,
      metadata: { circus_id: circus.id }
    })
    circus.update!(stripe_customer_id: customer.id)
    customer.id
  end
end
