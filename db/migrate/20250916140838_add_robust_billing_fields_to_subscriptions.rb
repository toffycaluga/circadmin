class AddRobustBillingFieldsToSubscriptions < ActiveRecord::Migration[8.0]
  def change
    # Campos de idempotencia y tracking
    add_column :subscriptions, :checkout_session_id, :string unless column_exists?(:subscriptions, :checkout_session_id)
    add_column :subscriptions, :stripe_customer_id, :string unless column_exists?(:subscriptions, :stripe_customer_id)

    # Estados operativos
    add_column :subscriptions, :active, :boolean, default: false, null: false unless column_exists?(:subscriptions, :active)
    add_column :subscriptions, :cancel_at_period_end, :boolean, default: false, null: false unless column_exists?(:subscriptions, :cancel_at_period_end)

    # Índices útiles
    add_index :subscriptions, :checkout_session_id, unique: true, if_not_exists: true
    add_index :subscriptions, :stripe_subscription_id, unique: true, if_not_exists: true

    # Garantía: una sola activa por circo
    reversible do |dir|
      dir.up do
        execute <<~SQL
          CREATE UNIQUE INDEX IF NOT EXISTS index_subscriptions_one_active_per_circus
          ON subscriptions (circus_id)
          WHERE active = TRUE;
        SQL
      end
      dir.down do
        execute <<~SQL
          DROP INDEX IF EXISTS index_subscriptions_one_active_per_circus;
        SQL
      end
    end
  end
end
