FactoryBot.define do
  factory :volunteer do
    role { Volunteer.roles.keys.sample }
    athlete

    transient do
      activity_params { {} }
    end

    activity { association(:activity, **activity_params) }
  end
end
