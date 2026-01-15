class RemovePayrollTransactionIdFromPayrolls < ActiveRecord::Migration[8.0]
  def change
    remove_column :payrolls, :payroll_transaction_id, :integer
  end
end
