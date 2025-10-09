class AddStripeSubscriptionItemIdToSubscriptionItems < ActiveRecord::Migration[8.0]
  def change
    # Relación con la suscripción madre
    unless column_exists?(:subscription_items, :subscription_id)
      add_reference :subscription_items, :subscription, null: false, foreign_key: true
    end

    # Columnas mínimas para Opción B (agrega solo si faltan)
    add_column :subscription_items, :stripe_subscription_item_id, :string unless column_exists?(:subscription_items, :stripe_subscription_item_id)
    add_column :subscription_items, :stripe_product_id,          :string unless column_exists?(:subscription_items, :stripe_product_id)
    add_column :subscription_items, :price_id,                   :string unless column_exists?(:subscription_items, :price_id)
    add_column :subscription_items, :service_key,                :string, null: false, default: "core" unless column_exists?(:subscription_items, :service_key)
    add_column :subscription_items, :quantity,                   :integer, null: false, default: 1 unless column_exists?(:subscription_items, :quantity)
    add_column :subscription_items, :active,                     :boolean, null: false, default: true unless column_exists?(:subscription_items, :active)

    # Datos informativos del Price (opcionales pero útiles)
    add_column :subscription_items, :unit_amount,     :integer unless column_exists?(:subscription_items, :unit_amount)
    add_column :subscription_items, :currency,        :string  unless column_exists?(:subscription_items, :currency)
    add_column :subscription_items, :interval,        :string  unless column_exists?(:subscription_items, :interval)
    add_column :subscription_items, :interval_count,  :integer unless column_exists?(:subscription_items, :interval_count)

    # Índices
    add_index :subscription_items, :stripe_subscription_item_id, unique: true, if_not_exists: true
    add_index :subscription_items, :service_key, if_not_exists: true

    # Índice parcial: "un item activo por servicio dentro de la misma suscripción"
    reversible do |dir|
      dir.up do
        execute <<~SQL
          CREATE UNIQUE INDEX IF NOT EXISTS idx_one_active_item_per_service
          ON subscription_items (subscription_id, service_key)
          WHERE active = TRUE;
        SQL
      end
      dir.down do
        execute <<~SQL
          DROP INDEX IF EXISTS idx_one_active_item_per_service;
        SQL
      end
    end
  end
end
