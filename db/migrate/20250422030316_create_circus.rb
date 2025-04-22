class CreateCircuses < ActiveRecord::Migration[8.0]
  def change
    create_table :circuses do |t|
      t.string :name
      t.text :description
      t.string :country
      t.string :currency
      t.boolean :active
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
