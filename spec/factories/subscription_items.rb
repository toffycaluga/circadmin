# == Schema Information
#
# Table name: subscription_items
#
#  id                          :integer          not null, primary key
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  subscription_id             :integer          not null
#  stripe_subscription_item_id :string
#  stripe_product_id           :string
#  price_id                    :string
#  service_key                 :string           default("core"), not null
#  quantity                    :integer          default("1"), not null
#  active                      :boolean          default("true"), not null
#  unit_amount                 :integer
#  currency                    :string
#  interval                    :string
#  interval_count              :integer
#
# Indexes
#
#  idx_one_active_item_per_service                          (subscription_id,service_key) UNIQUE
#  index_subscription_items_on_service_key                  (service_key)
#  index_subscription_items_on_stripe_subscription_item_id  (stripe_subscription_item_id) UNIQUE
#  index_subscription_items_on_subscription_id              (subscription_id)
#  uniq_active_item_per_service_per_subscription            (subscription_id,service_key) UNIQUE
#

FactoryBot.define do
  factory :subscription_item do
     association :subscription
    stripe_subscription_item_id { "si_test_#{SecureRandom.hex(4)}" }
    stripe_product_id { "prod_test_123" }
    price_id { "price_test_123" }
    service_key { "core" }
    quantity { 1 }
    active { true }
    unit_amount { 2000 }
    currency { "eur" }
    interval { "month" }
    interval_count { 1 }
  end
end
