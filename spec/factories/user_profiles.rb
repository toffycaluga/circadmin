# == Schema Information
#
# Table name: user_profiles
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  full_name  :string
#  address    :string
#  country    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_user_profiles_on_user_id  (user_id)
#

FactoryBot.define do
  factory :user_profile do
    user { nil }
    nombre_completo { "MyString" }
    direccion { "MyString" }
    pais { "MyString" }
    tipo_moneda { "MyString" }
  end
end
