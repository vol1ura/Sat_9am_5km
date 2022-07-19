FactoryBot.define do
  factory :badge do
    name { Faker::Fantasy::Tolkien.character }
    conditions { Faker::Lorem.paragraph }
    picture_link { 'badges/sm_fest.png' }
  end
end
