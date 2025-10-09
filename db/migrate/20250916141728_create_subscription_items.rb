class CreateSubscriptionItems < ActiveRecord::Migration[8.0]
  def change
    create_table :subscription_items do |t|
      t.references :subscription, null: false, foreign_key: true

      t.string :stripe_subscription_item_id, null: false
      t.string :stripe_product_id,          null: false
      t.string :price_id,                   null: false
      t.string :service_key,                null: false  # "core", "ticketing", "concessions", etc.
      t.integer :quantity,                  null: false, default: 1
      t.boolean :active,                    null: false, default: true

      # (Opcional) para mostrar info rápidamente sin ir a Stripe
      t.integer :unit_amount                # en centavos
      t.string  :currency
      t.string  :interval                   # "month", "year"
      t.integer :interval_count

      t.timestamps
    end

    add_index :subscription_items, :stripe_subscription_item_id, unique: true
    add_index :subscription_items, :service_key
    # Evita 2 items activos del mismo servicio en la misma suscripción
    execute <<~SQL
      CREATE UNIQUE INDEX IF NOT EXISTS idx_one_active_item_per_service
      ON subscription_items (subscription_id, service_key)
      WHERE active = TRUE;
    SQL
  end
end
