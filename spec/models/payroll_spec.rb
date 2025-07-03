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

require 'rails_helper'

RSpec.describe Payroll, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
