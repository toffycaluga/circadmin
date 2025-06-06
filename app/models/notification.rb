class Notification < ApplicationRecord
  belongs_to :user
  # app/models/notification.rb
  scope :unread, -> { where(read: false) }

end
