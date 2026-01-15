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

FactoryBot.define do
  factory :payroll do
    title { "MyString" }
    date { "2025-06-23" }
    total { "9.99" }
    circus { nil }
    payroll_transaction { nil }
  end
end
