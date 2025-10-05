class AddStripeCustomerIdToCircuses < ActiveRecord::Migration[8.0]
  def change
    add_column :circuses, :stripe_customer_id, :string unless column_exists?(:circuses, :stripe_customer_id)
    add_index  :circuses, :stripe_customer_id, unique: true, if_not_exists: true
  end
end
