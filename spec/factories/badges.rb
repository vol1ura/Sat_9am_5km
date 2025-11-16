# frozen_string_literal: true

FactoryBot.define do
  factory :badge do
    name { Faker::Fantasy::Tolkien.character }
    conditions { Faker::Lorem.paragraph }
    after(:build) do |badge|
      badge.image.attach(
        io: File.open('spec/fixtures/files/default.png'),
        filename: 'default.png',
      )
    end

    factory :participating_badge do
      transient do
        threshold { 25 }
        type { 'result' }
      end
      kind { :participating }
      info { { threshold:, type: } }
    end
  end
end
