FactoryBot.define do
  factory :result do
    sequence :position
    total_time { Result.total_time(18, 10) + (position * 2).seconds }
    athlete

    transient do
      activity_params { {} }
    end

    activity { association(:activity, **activity_params) }
  end
end
