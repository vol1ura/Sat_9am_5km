# frozen_string_literal: true

if Rails.env.development?
  user = User.find_or_create_by!(email: 'admin@test.com') do |u|
    u.password = '111111'
    u.password_confirmation = '111111'
    u.role = 0
    u.first_name = 'John'
    u.last_name = 'Doe'
  end
  user.update!(locked_at: nil) if user.locked_at.present?
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
