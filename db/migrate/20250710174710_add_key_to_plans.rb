class AddKeyToPlans < ActiveRecord::Migration[8.0]
  def change
    add_column :plans, :key, :string, null: false
    add_index :plans, :key, unique: true
  end
end
