class AddPayrollToTransactions < ActiveRecord::Migration[8.0]
  def change
    add_reference :transactions, :payroll,
                    foreign_key: true,
                    index: true,
                    null: true     # <–– permitir NULL para las transacciones antiguas

  end
end
