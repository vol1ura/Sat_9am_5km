FactoryBot.define do
  factory :contact do
    link { Faker::Internet.url }
    contact_type { random(8) }
    event
  end
end
