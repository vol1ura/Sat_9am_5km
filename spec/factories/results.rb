FactoryBot.define do
  factory :result do
    sequence :position
    athlete
    activity
    total_time { Time.zone.local(2000, 1, 1, 0, 18, 10) + (position * 2).seconds }
  end
end
