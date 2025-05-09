# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { Faker::Name.male_first_name }
    last_name { Faker::Name.male_last_name }
    telegram_user { Faker::Internet.username }
    telegram_id { Faker::Number.number(digits: 10) }

    trait :admin do
      role { :admin }
    end

    trait :with_email do
      email { Faker::Internet.email }
      password { Faker::Internet.password(min_length: 6) }
      telegram_user { nil }
      telegram_id { nil }
    end

    transient do
      with_avatar { false }
    end

    after(:build) do |user, evaluator|
      user.skip_confirmation_notification!
      user.image.attach(io: File.open('spec/fixtures/files/default.png'), filename: 'avatar.png') if evaluator.with_avatar
    end

    after :create, &:confirm
  end
end
