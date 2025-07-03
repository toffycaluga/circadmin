class CreatePayrollItems < ActiveRecord::Migration[8.0]
  def change
    create_table :payroll_items do |t|
      t.references :payroll, null: false, foreign_key: true
      t.string :name
      t.string :role
      t.decimal :amount
      t.text :notes

      t.timestamps
    end
  end
end
