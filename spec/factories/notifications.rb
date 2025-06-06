FactoryBot.define do
  factory :notification do
    user { nil }
    title { "MyString" }
    body { "MyText" }
    read { false }
  end
end
