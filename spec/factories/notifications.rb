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

FactoryBot.define do
  factory :notification do
    user { nil }
    title { "MyString" }
    body { "MyText" }
    read { false }
  end
end
