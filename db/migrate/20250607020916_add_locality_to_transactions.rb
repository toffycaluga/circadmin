class AddLocalityToTransactions < ActiveRecord::Migration[8.0]
  def change
    add_reference :transactions, :locality, null: false, foreign_key: true
  end
end
