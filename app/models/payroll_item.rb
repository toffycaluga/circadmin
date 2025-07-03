# == Schema Information
#
# Table name: payroll_items
#
#  id         :integer          not null, primary key
#  payroll_id :integer          not null
#  name       :string
#  role       :string
#  amount     :decimal(, )
#  notes      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_payroll_items_on_payroll_id  (payroll_id)
#

class PayrollItem < ApplicationRecord
  belongs_to :payroll

  validates :name, :role, :amount, presence: true

  after_save :update_payroll_total
  after_destroy :update_payroll_total

  private

  def update_payroll_total
    payroll.recalculate_total!
  end
end
