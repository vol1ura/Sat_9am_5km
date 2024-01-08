# frozen_string_literal: true

FactoryBot.define do
  factory :athlete do
    name { Faker::Name.name }
    parkrun_code { Faker::Number.number(digits: 6) }
    fiveverst_code { Faker::Number.between(from: Athlete::FIVE_VERST_BORDER, to: Athlete::FIVE_VERST_BORDER + (10**7) - 1) }
    male { true }
  end
end
