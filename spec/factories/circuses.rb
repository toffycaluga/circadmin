# == Schema Information
#
# Table name: circuses
#
#  id                          :integer          not null, primary key
#  name                        :string
#  description                 :text
#  country                     :string
#  currency                    :string
#  active                      :boolean          default("true")
#  user_id                     :integer          not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  stripe_customer_id          :string
#  had_trial                   :boolean          default("false"), not null
#  stripe_subscription_status  :string
#  stripe_current_period_end   :datetime
#  stripe_cancel_at_period_end :boolean
#  stripe_pause_collection     :jsonb
#
# Indexes
#
#  index_circuses_on_stripe_customer_id  (stripe_customer_id)
#  index_circuses_on_user_id             (user_id)
#

FactoryBot.define do
  factory :circus do
    association :user
    name { "Circo #{SecureRandom.hex(3)}" }
    country { "CL" }
    currency { "CLP" }
    active { true }
  end
end
