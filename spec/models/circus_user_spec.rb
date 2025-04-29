# == Schema Information
#
# Table name: circus_users
#
#  id                 :integer          not null, primary key
#  user_id            :integer          not null
#  circus_id          :integer          not null
#  role               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  invitation_sent_at :datetime
#  accepted_at        :datetime
#
# Indexes
#
#  index_circus_users_on_circus_id  (circus_id)
#  index_circus_users_on_user_id    (user_id)
#

require 'rails_helper'

RSpec.describe CircusUser, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
