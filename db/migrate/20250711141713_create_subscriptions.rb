class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.references :circus,                   null: false, foreign_key: true
      t.string     :stripe_subscription_id,   null: false
      t.string     :status,                   null: false
      t.datetime   :current_period_start,     null: false
      t.datetime   :current_period_end,       null: false
      t.string     :price_id,                 null: false
      t.timestamps
    end
  end
end
