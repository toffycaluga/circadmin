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

class Subscription < ApplicationRecord
  belongs_to :circus
  has_many :subscription_items, dependent: :destroy

  STATUSES = %w[
    incomplete
    incomplete_expired
    trialing
    active
    past_due
    canceled
    unpaid
    paused
  ].freeze

  validates :stripe_subscription_id, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  STATUSES.each { |st| define_method("#{st}?") { status.to_s == st } }

  def active_items
    subscription_items.active_only
  end

  def subscribed_to?(service_key)
    active_items.where(service_key: service_key).exists?
  end

  def item_for(service_key)
    subscription_items.find_by(service_key: service_key, active: true)
  end
end
