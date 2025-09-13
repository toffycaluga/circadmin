class AddForeignKeyToSubscriptions < ActiveRecord::Migration[8.0]
  def change
    # añade la restricción sólo si no existe
    unless foreign_key_exists?(:subscriptions, :circuses)
      add_foreign_key :subscriptions, :circuses
    end
  end
end
