# frozen_string_literal: true

FactoryBot.define do
  factory :newsletter do
    body { Faker::Lorem.paragraph }
  end
end
