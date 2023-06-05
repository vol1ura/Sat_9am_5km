FactoryBot.define do
  factory :event do
    name { Faker::Team.name }
    sequence(:code_name, 'aa') { |c| "event_#{c}" }
    town { Faker::Address.city }
    place { Faker::Address.street_name }
    description { Faker::Lorem.paragraph }
  end
end
