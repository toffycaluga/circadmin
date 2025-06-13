# == Schema Information
#
# Table name: transactions
#
#  id               :integer          not null, primary key
#  title            :string
#  amount           :decimal(10, 2)
#  transaction_type :string
#  description      :text
#  date             :datetime
#  user_id          :integer          not null
#  circus_id        :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  category         :string
#  locality_id      :integer          not null
#
# Indexes
#
#  index_transactions_on_circus_id    (circus_id)
#  index_transactions_on_locality_id  (locality_id)
#  index_transactions_on_user_id      (user_id)
#

class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :circus
  belongs_to :locality

  has_one_attached :receipt

  scope :incomes, -> { where(transaction_type: "income") }
  scope :expenses, -> { where(transaction_type: "expense") }

  # ✅ enum definido correctamente
  # enum transaction_type: { income: "income", expense: "expense" }, _suffix: true
  # Elimina esta línea:
  # enum transaction_type: { income: "income", expense: "expense" }, _suffix: true

  # Y reemplazalo con métodos personalizados:
  def transaction_type_income?
    transaction_type == "income"
  end

  def transaction_type_expense?
    transaction_type == "expense"
  end


  validates :title, :amount, :transaction_type, :date, presence: true

  INCOME_CATEGORIES = %w[ticket_sales events candy souvenirs others]
  EXPENSE_CATEGORIES = %w[payroll rent transport food permits others]

  # ✅ estos métodos deben ir *fuera* de cualquier bloque o macro
  def transaction_type_income?
    transaction_type == "income"
  end

  def transaction_type_expense?
    transaction_type == "expense"
  end

  private

  def receipt_required_for_expenses
    if transaction_type_expense? && !receipt.attached?
      errors.add(:receipt, "debe ser adjuntado para gastos")
    end
  end
end
