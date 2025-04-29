class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  has_one :user_profile, dependent: :destroy
  has_many :circus_users
  has_many :circuses, through: :circus_users


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
