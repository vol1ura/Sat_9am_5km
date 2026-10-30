# frozen_string_literal: true

FactoryBot.define do
  factory :team_member do
    athlete
    role { Faker::Job.title }
    sequence :rank
    after(:build) do |member|
      member.photo.attach(
        io: File.open('spec/fixtures/files/default.png'),
        filename: 'default.png',
      )
    end
  end
end
