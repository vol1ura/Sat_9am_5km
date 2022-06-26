if Rails.env.development?
  User.create!(
      email: 'admin@test.com',
      password: '111111',
      password_confirmation: '111111',
      role: :admin,
      first_name: 'John',
      last_name: 'Doe'
  )
end
Event.create!(
  code_name: 'kuzminki',
  town: 'Москва',
  place: 'парке Кузьминки',
  description: 'Каждую субботу сбор в 8:45 возле сцены.'
)
Event.create!(
  code_name: 'olimpiyskaya_derevnya',
  town: 'Москва',
  place: 'парке Олимпийская Деревня',
  description: 'Каждую субботу сбор в 8:45 где-то в парке.'
)
