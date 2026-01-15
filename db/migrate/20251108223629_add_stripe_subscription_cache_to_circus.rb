class AddStripeSubscriptionCacheToCircus < ActiveRecord::Migration[8.0]
  def change
    add_column :circuses, :stripe_subscription_status, :string
    add_column :circuses, :stripe_current_period_end, :datetime
    add_column :circuses, :stripe_cancel_at_period_end, :boolean
    add_column :circuses, :stripe_pause_collection, :jsonb
  end
end
