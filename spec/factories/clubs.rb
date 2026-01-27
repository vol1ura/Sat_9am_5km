# frozen_string_literal: true

FactoryBot.define do
  factory :club do
    name { Faker::Team.name }
    country_id { 1 }
    slug { Faker::Alphanumeric.alphanumeric(number: 10) }
  end
end
