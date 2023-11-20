FactoryBot.define do
  factory :club do
    name { Faker::Team.name }
    country_id { 1 }
  end
end
