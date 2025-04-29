# == Schema Information
#
# Table name: circus_users
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  circus_id  :integer          not null
#  role       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_circus_users_on_circus_id  (circus_id)
#  index_circus_users_on_user_id    (user_id)
#

class CircusUser < ApplicationRecord
  belongs_to :user
  belongs_to :circus

  ROLES = %w[admin contador representante dueño]

  validates :role, presence: true, inclusion: { in: ROLES }
end
