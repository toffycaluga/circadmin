# == Schema Information
#
# Table name: localities
#
#  id         :integer          not null, primary key
#  title      :string
#  location   :string
#  city       :string
#  start_date :date
#  end_date   :date
#  active     :boolean
#  circus_id  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_localities_on_circus_id  (circus_id)
#

FactoryBot.define do
  factory :locality do
    title { "MyString" }
    location { "MyString" }
    city { "MyString" }
    start_date { "2025-06-06" }
    end_date { "2025-06-06" }
    active { false }
    notes { "MyText" }
    circus { nil }
  end
end
