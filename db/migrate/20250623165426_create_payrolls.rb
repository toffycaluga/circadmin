class CreatePayrolls < ActiveRecord::Migration[8.0]
  def change
    create_table :payrolls do |t|
      t.string :title
      t.date :date
      t.decimal :total
      t.references :circus, null: false, foreign_key: true
      t.references :payroll_transaction, null: false, foreign_key: { to_table: :transactions }

      t.timestamps
    end
  end
end
