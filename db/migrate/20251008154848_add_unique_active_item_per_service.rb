class AddUniqueActiveItemPerService < ActiveRecord::Migration[8.0]
    def change
      add_index :subscription_items,
                [ :subscription_id, :service_key ],
                unique: true,
                where: "active = TRUE",
                name: "uniq_active_item_per_service_per_subscription"
    end
end
