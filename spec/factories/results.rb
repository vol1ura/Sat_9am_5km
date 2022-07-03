FactoryBot.define do
  factory :result do
    sequence :position
    athlete
    activity
  end
end
