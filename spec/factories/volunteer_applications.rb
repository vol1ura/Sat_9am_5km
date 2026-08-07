# frozen_string_literal: true

FactoryBot.define do
  factory :volunteer_application do
    activity { association :activity, published: false, date: Date.tomorrow }
    athlete { association :athlete, :with_user }
    role { :director }
  end
end
