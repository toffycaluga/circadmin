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

require 'rails_helper'

RSpec.describe Notification, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
