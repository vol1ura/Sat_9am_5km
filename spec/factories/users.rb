FactoryBot.define do
  factory :user do
    first_name { Faker::Name.male_first_name }
    last_name { Faker::Name.male_last_name }
    email { Faker::Internet.email }
    password { Faker::Internet.password(min_length: 6) }

    after :build, &:skip_confirmation_notification!

    after :create, &:confirm
  end
end
