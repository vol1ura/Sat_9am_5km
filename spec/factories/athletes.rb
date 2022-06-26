FactoryBot.define do
  factory :athlete do
    name { Faker::Name.name }
    parkrun_code { Faker::Number.number(digits: 6) }
    fiveverst_code { Faker::Number.between(from: 790000000, to: 799999999) }
    male { true }
  end
end
