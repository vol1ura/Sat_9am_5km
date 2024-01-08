# frozen_string_literal: true

FactoryBot.define do
  factory :activity do
    date { Faker::Date.backward(days: 30) }
    description { Faker::Lorem.paragraph }
    event
    published { true }
  end
end
