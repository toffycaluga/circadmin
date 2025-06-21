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

require 'rails_helper'

RSpec.describe Transaction, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
