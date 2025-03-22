# frozen_string_literal: true

FactoryBot.define do
  factory :friendship do
    athlete
    friend { association :athlete }
  end
end
