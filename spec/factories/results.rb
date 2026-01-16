# frozen_string_literal: true

FactoryBot.define do
  factory :result do
    sequence :position
    total_time { (18 * 60) + 10 + (position * 2) }
    athlete
    first_run { !athlete&.results&.exists? }
    personal_best { !athlete&.results&.exists? }

    transient do
      activity_params { {} }
    end

    activity { association(:activity, **activity_params) }
  end
end
