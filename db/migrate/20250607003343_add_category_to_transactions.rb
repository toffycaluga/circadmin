class AddCategoryToTransactions < ActiveRecord::Migration[8.0]
 def change
    change_column :transactions, :transaction_type, :integer, using: "transaction_type::integer"
  end
end
