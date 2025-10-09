class CreatePlans < ActiveRecord::Migration[8.0]
  def change
    create_table :plans do |t|
      t.string  :name,              null: false
      t.string  :stripe_price_id,   null: false, index: true
      t.integer :price_cents,       null: false
      t.integer :allowed_circuses,  null: false
      t.text    :features
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    # add_index :plans, :stripe_price_id, unique: true
  end
end
