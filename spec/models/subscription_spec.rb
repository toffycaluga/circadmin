# == Schema Information
#
# Table name: subscriptions
#
#  id                     :integer          not null, primary key
#  circus_id              :integer          not null
#  stripe_subscription_id :string           not null
#  status                 :string           not null
#  current_period_start   :datetime         not null
#  current_period_end     :datetime         not null
#  price_id               :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_subscriptions_on_circus_id  (circus_id)
#

require 'rails_helper'

RSpec.describe Subscription, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
