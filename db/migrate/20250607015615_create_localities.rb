class CreateLocalities < ActiveRecord::Migration[8.0]
  def change
    create_table :localities do |t|
      t.string :title
      t.string :location
      t.string :city
      t.date :start_date
      t.date :end_date
      t.boolean :active
      t.text :notes
      t.references :circus, null: false, foreign_key: true

      t.timestamps
    end
  end
end
