FactoryBot.define do
  factory :result do
    sequence :position
    athlete
    activity
    total_time { "0:18:#{10 + (2 * position)}" }
  end
end
