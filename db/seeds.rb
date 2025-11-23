# frozen_string_literal: true

if Rails.env.development?
  User.create!(
    email: 'admin@test.com',
    password: '111111',
    password_confirmation: '111111',
    role: 0,
    first_name: 'John',
    last_name: 'Doe'
  )
end

russia = Country.create!(code: 'ru')

Event.create!(
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
