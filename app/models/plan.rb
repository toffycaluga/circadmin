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

class Plan < ApplicationRecord
     has_many :subscriptions, dependent: :nullify

    validates :key,            presence: true, uniqueness: true
    validates :stripe_price_id, :price_cents, :allowed_circuses, :trial_days, presence: true

    scope :active, -> { where(active: true) }
end
