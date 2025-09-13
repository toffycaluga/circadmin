class AddStripeToCircuses < ActiveRecord::Migration[8.0]
  def change
    add_column :circuses, :stripe_customer_id, :string
  end
end
