# == Schema Information
#
# Table name: subscriptions
#
#  id                     :integer          not null, primary key
#  circus_id              :integer          not null
#  stripe_subscription_id :string           not null
#  status                 :string           not null
#  current_period_start   :datetime         not null
#  current_period_end     :datetime         not null
#  price_id               :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  checkout_session_id    :string
#  stripe_customer_id     :string
#  active                 :boolean          default("false"), not null
#  cancel_at_period_end   :boolean          default("false"), not null
#
# Indexes
#
#  index_subscriptions_on_checkout_session_id     (checkout_session_id) UNIQUE
#  index_subscriptions_on_circus_id               (circus_id)
#  index_subscriptions_on_price_id                (price_id)
#  index_subscriptions_on_stripe_subscription_id  (stripe_subscription_id) UNIQUE
#  index_subscriptions_one_active_per_circus      (circus_id) UNIQUE
#

FactoryBot.define do
  factory :subscription do
    circus { nil }
    stripe_subscription_id { "MyString" }
    status { "MyString" }
    current_period_start { "2025-07-11 10:17:13" }
    current_period_end { "2025-07-11 10:17:13" }
    price_id { "MyString" }
  end
end
