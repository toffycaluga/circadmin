FactoryBot.define do
  factory :circus do
    association :user
    name { "Circo #{SecureRandom.hex(3)}" }
    country { "CL" }
    currency { "CLP" }
    active { true }
  end
end
