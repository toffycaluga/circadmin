class AddBillingAuditToSubscriptions < ActiveRecord::Migration[8.0]
  def change
    add_column :subscriptions, :latest_invoice_id,     :string
    add_column :subscriptions, :latest_invoice_status, :string
    add_column :subscriptions, :latest_charge_id,      :string
    add_column :subscriptions, :paid_through_at,       :datetime

    # Una sola suscripción activa por circo
    add_index :subscriptions,
              :circus_id,
              unique: true,
              where: "active = TRUE",
              name: "uniq_active_subscription_per_circus"
  end
end
