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

FactoryBot.define do
  factory :payment_method do
    circus { nil }
    stripe_payment_method_id { "MyString" }
    card_brand { "MyString" }
    last4 { "MyString" }
    exp_month { 1 }
    exp_year { 1 }
    default { false }
  end
end
