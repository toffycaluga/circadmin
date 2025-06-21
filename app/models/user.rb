# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_type        :string
#  invited_by_id          :integer
#  invitations_count      :integer          default("0")
#  inviting_circus_id     :integer
#  superadmin             :boolean          default("false"), not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_invitation_token      (invitation_token) UNIQUE
#  index_users_on_invited_by            (invited_by_type,invited_by_id)
#  index_users_on_invited_by_id         (invited_by_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable, :confirmable


  has_one :user_profile, dependent: :destroy
  has_many :circus_users
  has_many :circuses, through: :circus_users
  has_many :invitations
  has_many :sent_invitations, class_name: "Invitation", foreign_key: :sender_id
  has_many :notifications, dependent: :destroy
  has_many :documents


  def unread_notifications
    notifications.where(read: false)
  end

  def send_reset_password_instructions
    raw_token, enc_token = Devise.token_generator.generate(self.class, :reset_password_token)
    self.reset_password_token = enc_token
    self.reset_password_sent_at = Time.current
    save(validate: false)
    send_devise_notification(:reset_password_instructions, raw_token, {})
    raw_token
  end

  after_create :create_blank_profile
  # Circenses donde soy el dueño (owner directo)
  def owned_circuses
    Circus.where(user_id: id)
  end

  # Circenses donde estoy asociado con un rol
  def associated_circuses
    circuses # from has_many :circuses, through: :circus_users
  end

  private

  def create_blank_profile
    create_user_profile!
  end
end
