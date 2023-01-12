FactoryBot.define do
  factory :volunteering_position do
    sequence :rank
    role { Volunteer::ROLES.keys.sample }
    number { Faker::Number.between(from: 1, to: 4) }
    event
  end
end
