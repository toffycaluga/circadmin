# == Schema Information
#
# Table name: notifications
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  title      :string
#  body       :text
#  read       :boolean          default("false")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_notifications_on_user_id  (user_id)
#

class Notification < ApplicationRecord
  belongs_to :user
  # app/models/notification.rb
  scope :unread, -> { where(read: false) }

  def unread?
    !read
  end
end
