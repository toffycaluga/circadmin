class MakeSubscriptionsPriceIdNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :subscriptions, :price_id, true
  end
end
