# == Schema Information
#
# Table name: invitations
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  circus_id  :integer          not null
#  sender_id  :integer          not null
#  message    :text
#  status     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_invitations_on_circus_id  (circus_id)
#  index_invitations_on_sender_id  (sender_id)
#  index_invitations_on_user_id    (user_id)
#

class Invitation < ApplicationRecord
  belongs_to :user
  belongs_to :circus
  belongs_to :sender, class_name: "User"

  STATUSES = { "pending" => 0, "accepted" => 1, "rejected" => 2 }

  def status_name
    STATUSES.key(self[:status]) || "unknown"
  end

  validates :message, presence: true

  after_create :notify_user

  private

  def notify_user
    InvitationMailer.notify(self).deliver_later
  end
end
