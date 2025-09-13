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
#  price_id               :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_subscriptions_on_circus_id  (circus_id)
#

class Subscription < ApplicationRecord
  belongs_to :circus

  # Enum string-backed (Rails 7.1+/8). Si tu versión es menor y te da guerra,
  # usa la opción "validates inclusion" indicada en mensajes anteriores.
  enum :status, {
    active:   "active",
    past_due: "past_due",
    paused:   "paused",
    canceled: "canceled"
  }, prefix: true, validate: true
end
