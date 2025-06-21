class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.string :title
      t.decimal :amount, precision: 10, scale: 2
      t.string :transaction_type
      t.text :description
      t.datetime :date
      t.references :user, null: false, foreign_key: true
      t.references :circus, null: false, foreign_key: true

      t.timestamps
    end
  end
end
