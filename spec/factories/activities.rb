FactoryBot.define do
  factory :activity do
    date { Faker::Date.backward(days: 30) }
    description { Faker::Lorem.paragraph }
    event
  end
end
