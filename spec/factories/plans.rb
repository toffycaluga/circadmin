# == Schema Information
#
# Table name: plans
#
#  id               :integer          not null, primary key
#  name             :string           not null
#  stripe_price_id  :string           not null
#  price_cents      :integer          not null
#  allowed_circuses :integer          not null
#  features         :text
#  active           :boolean          default("true"), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  trial_days       :integer          default("0"), not null
#  key              :string           not null
#
# Indexes
#
#  index_plans_on_key              (key) UNIQUE
#  index_plans_on_stripe_price_id  (stripe_price_id)
#

FactoryBot.define do
  factory :plan do
    key { "basic" }
    name { "Basic" }
    price_cents { 2000 }
    active { true }
    stripe_price_id { "price_test_123" }
    trial_days { 14 }
    # name { "MyString" }
    # stripe_price_id { "MyString" }
    # price_cents { 1 }
    # allowed_circuses { 1 }
    # features { "MyText" }
    # active { false }
  end
end
