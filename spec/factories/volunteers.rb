FactoryBot.define do
  factory :volunteer do
    role { Volunteer::ROLES.keys.sample }
    activity
    athlete

    trait :with_published_activity do
      association :activity, published: true
    end
  end
end
