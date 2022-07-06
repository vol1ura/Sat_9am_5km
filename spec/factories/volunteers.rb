FactoryBot.define do
  factory :volunteer do
    role { Volunteer::ROLES.keys.sample }
    activity
    athlete
  end
end
