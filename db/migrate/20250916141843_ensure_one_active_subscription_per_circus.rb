class EnsureOneActiveSubscriptionPerCircus < ActiveRecord::Migration[8.0]
  def change
    # Quita el índice por servicio si existía:
    execute <<~SQL
      DROP INDEX IF EXISTS index_subscriptions_one_active_per_circus_service;
    SQL

    # Crea el índice por circo:
    execute <<~SQL
      CREATE UNIQUE INDEX IF NOT EXISTS index_subscriptions_one_active_per_circus
      ON subscriptions (circus_id)
      WHERE active = TRUE;
    SQL
  end
end
