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

require 'rails_helper'

RSpec.describe PayrollItem, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
