# == Schema Information
#
# Table name: payrolls
#
#  id         :integer          not null, primary key
#  title      :string
#  date       :date
#  total      :decimal(, )
#  circus_id  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_payrolls_on_circus_id  (circus_id)
#

class Payroll < ApplicationRecord
  belongs_to :circus
  has_many :payroll_items, dependent: :destroy

  # Esta asociación permite hacer payroll.payroll_transaction
  has_one    :payroll_transaction,
             -> { where(transaction_type: "expense", category: "payroll") },
             class_name: "Transaction",
             foreign_key: "payroll_id",
             dependent: :nullify

  validates :title, :date, presence: true

  def recalculate_total!
    update!(total: payroll_items.sum(:amount))
  end

  def transaction_registered?
    Transaction.exists?(
      title: title,
      transaction_type: "expense",
      category: "payroll",
      circus_id: circus_id
    )
  end

  def total_amount
    payroll_items.sum(:amount)
  end
end
