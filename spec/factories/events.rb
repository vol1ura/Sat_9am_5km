FactoryBot.define do
  factory :event do
    code_name { Faker::Internet.slug(glue: '_') }
    town { Faker::Address.city }
    place { Faker::Address.street_name }
    description { Faker::Lorem.paragraph }
  end
end
