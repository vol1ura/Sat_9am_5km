FactoryBot.define do
  factory :club do
    name { Faker::Team.name }
  end
end
