# == Schema Information
#
# Table name: circuses
#
#  id                 :integer          not null, primary key
#  name               :string
#  description        :text
#  country            :string
#  currency           :string
#  active             :boolean          default("true")
#  user_id            :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  stripe_customer_id :string
#  had_trial          :boolean          default("false"), not null
#
# Indexes
#
#  index_circuses_on_stripe_customer_id  (stripe_customer_id)
#  index_circuses_on_user_id             (user_id)
#

class Circus < ApplicationRecord
  belongs_to :user
  has_one_attached :logo
  has_many :circus_users, dependent: :destroy
  has_many :users, through: :circus_users
  has_many :invitations
  has_many :localities, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :payrolls
  has_many :payment_methods, dependent: :destroy
  has_many :subscriptions,     dependent: :destroy


  after_initialize :set_defaults, if: :new_record?

  private

  def set_defaults
    self.active = true if active.nil?
  end
end
