# == Schema Information
#
# Table name: circuses
#
#  id          :integer          not null, primary key
#  name        :string
#  description :text
#  country     :string
#  currency    :string
#  active      :boolean
#  user_id     :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_circuses_on_user_id  (user_id)
#

class Circus < ApplicationRecord
  belongs_to :user
  has_one_attached :logo
  has_many :circus_users
  has_many :users, through: :circus_users

  after_initialize :set_defaults, if: :new_record?

  private

  def set_defaults
    self.active = true if active.nil?
  end
end
