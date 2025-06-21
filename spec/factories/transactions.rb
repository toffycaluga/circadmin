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

FactoryBot.define do
  factory :transaction do
    title { "MyString" }
    amount { "9.99" }
    transaction_type { "MyString" }
    description { "MyText" }
    date { "2025-06-06 19:58:32" }
    user { nil }
    circus { nil }
  end
end
