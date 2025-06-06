# == Schema Information
#
# Table name: invitations
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  circus_id  :integer          not null
#  sender_id  :integer          not null
#  message    :text
#  status     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_invitations_on_circus_id  (circus_id)
#  index_invitations_on_sender_id  (sender_id)
#  index_invitations_on_user_id    (user_id)
#

require 'rails_helper'

RSpec.describe Invitation, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
