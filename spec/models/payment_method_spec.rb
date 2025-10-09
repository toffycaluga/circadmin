# == Schema Information
#
# Table name: payment_methods
#
#  id                       :integer          not null, primary key
#  circus_id                :integer          not null
#  stripe_payment_method_id :string           not null
#  card_brand               :string           not null
#  last4                    :string           not null
#  exp_month                :integer          not null
#  exp_year                 :integer          not null
#  default                  :boolean          default("false")
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
# Indexes
#
#  index_payment_methods_on_circus_id  (circus_id)
#

require 'rails_helper'

RSpec.describe PaymentMethod, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
