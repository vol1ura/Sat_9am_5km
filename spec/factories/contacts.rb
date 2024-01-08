# frozen_string_literal: true

FactoryBot.define do
  factory :contact do
    link { Faker::Internet.url }
    sequence :contact_type
    event
  end
end
