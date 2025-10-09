class ImproveStripeIndexes < ActiveRecord::Migration[8.0]
  def change
    add_index :subscriptions, :stripe_subscription_id, unique: true
    add_index :subscriptions, :price_id
    add_index :circuses,      :stripe_customer_id
  end
end
