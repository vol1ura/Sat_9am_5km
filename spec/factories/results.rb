FactoryBot.define do
  factory :result do
    sequence :position
    total_time { Time.zone.local(2000, 1, 1, 0, 18, 10) + (position * 2).seconds }
    athlete

    transient do
      activity_params { {} }
    end

    activity { association(:activity, **activity_params) }
  end
end
