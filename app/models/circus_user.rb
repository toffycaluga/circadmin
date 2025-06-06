# == Schema Information
#
# Table name: circus_users
#
#  id                 :integer          not null, primary key
#  user_id            :integer          not null
#  circus_id          :integer          not null
#  role               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  invitation_sent_at :datetime
#  accepted_at        :datetime
#  active             :boolean
#
# Indexes
#
#  index_circus_users_on_circus_id  (circus_id)
#  index_circus_users_on_user_id    (user_id)
#

class CircusUser < ApplicationRecord
  belongs_to :user
  belongs_to :circus

  ROLES = %w[admin accountant representative owner]
  scope :active, -> { where(active: true) }
  attribute :active, :boolean, default: true


  validates :role, presence: true, inclusion: { in: ROLES }
  validates :user_id, uniqueness: {
    scope: [ :circus_id ],
    conditions: -> { where(active: true) },
    message: "ya está activo en este circo"
  }


  def invitation_expired?
    invitation_sent_at.present? && invitation_sent_at < 48.hours.ago
  end
end
