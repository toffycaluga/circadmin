# == Schema Information
#
# Table name: invitations
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  circus_id  :integer          not null
#  sender_id  :integer          not null
#  message    :text
#  status     :integer          default("0"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_invitations_on_circus_id  (circus_id)
#  index_invitations_on_sender_id  (sender_id)
#  index_invitations_on_user_id    (user_id)
#

# app/models/invitation.rb
class Invitation < ApplicationRecord
  belongs_to :user
  belongs_to :circus
  belongs_to :sender, class_name: "User"

  STATUSES = { "pending" => 0, "accepted" => 1, "rejected" => 2 }

  validates :message, presence: true

  validate :no_pending_invitation_for_same_user_and_circus, on: :create

  after_create :notify_user

  def no_pending_invitation_for_same_user_and_circus
    if Invitation.where(user_id: user_id, circus_id: circus_id)
                .where(status: STATUSES["pending"])
                .exists?
      errors.add(:base, "Ya existe una invitación pendiente para este usuario en este circo.")
    end
  end


  def status_name
    STATUSES.key(self[:status]) || "unknown"
  end

  private

  def notify_user
    InvitationMailer.notify(self).deliver_later
  end
end
