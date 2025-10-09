# == Schema Information
#
# Table name: payroll_items
#
#  id         :integer          not null, primary key
#  payroll_id :integer          not null
#  name       :string
#  job_role   :string
#  amount     :decimal(, )
#  notes      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_payroll_items_on_payroll_id  (payroll_id)
#

FactoryBot.define do
  factory :payroll_item do
    payroll { nil }
    name { "MyString" }
    role { "MyString" }
    amount { "9.99" }
    notes { "MyText" }
  end
end
