# == Schema Information
#
# Table name: circus
#
#  id          :integer          not null, primary key
#  name        :string
#  description :text
#  country     :string
#  currency    :string
#  active      :boolean
#  user_id     :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_circus_on_user_id  (user_id)
#

class Circus < ApplicationRecord
  belongs_to :user
  has_one_attached :logo
end
