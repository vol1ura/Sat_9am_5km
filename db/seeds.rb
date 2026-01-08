# frozen_string_literal: true

user = User.create!(
  telegram_id: ENV['DEV_TELEGRAM_ID'],
  role: 0,
  first_name: 'John',
  last_name: 'Doe',
)

russia = Country.create!(code: 'ru')

kuzminki = Event.create!(
  name: 'Кузьминки',
  code_name: 'kuzminki',
  town: 'Москва',
  place: 'парк Кузьминки',
  description: 'Каждую субботу сбор в 8:45 возле сцены.',
  country: russia,
)
Event.create!(
  name: 'Олимпийская деревня',
  code_name: 'olimpiyskaya_derevnya',
  town: 'Москва',
  place: 'парк Олимпийская Деревня',
  description: 'Каждую субботу сбор в 8:45 где-то в парке.',
  country: russia,
)

club = Club.create!(
  name: Faker::Team.name,
  country: russia,
)

Athlete.create!(
  user: user,
  club: club,
  name: user.full_name,
  gender: 'male',
  event: kuzminki,
  fiveverst_code: 790000000 + Faker::Number.number(digits: 6),
)

50.times do
  Athlete.create!(
    name: Faker::Name.name,
    gender: Faker::Gender.binary_type.downcase,
    event: Event.order('RANDOM()').first,
    parkrun_code: Faker::Number.number(digits: 6),
  )
end
