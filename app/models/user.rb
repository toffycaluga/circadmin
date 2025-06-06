class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  has_one :user_profile, dependent: :destroy
  has_many :circus_users
  has_many :circuses, through: :circus_users
  has_many :invitations
  has_many :sent_invitations, class_name: "Invitation", foreign_key: :sender_id
  has_many :notifications, dependent: :destroy

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
