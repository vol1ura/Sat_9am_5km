# frozen_string_literal: true

# ВАЖНО: Этот файл только для разработки!
# Запускать: rails runner db/seeds_dev.rb
# НЕ коммитить созданные данные в основную базу

puts "🌱 Создание тестовых данных для проверки шрифтов..."

# Очистка старых тестовых данных
User.where(email: ['test1@example.com', 'test2@example.com', 'test3@example.com']).destroy_all
Athlete.where('name LIKE ?', 'Тест%').destroy_all

# Создание тестового события (если его еще нет)
event = Event.find_or_create_by!(code_name: 'test_park') do |e|
  e.name = 'Тестовый парк'
  e.town = 'Москва'
  e.place = 'Тестовая локация'
  e.description = 'Тестовое событие для проверки UI'
  e.country = Country.find_or_create_by!(code: 'ru')
end

puts "✅ Событие: #{event.name}"

# Создание тестовых пользователей и атлетов
test_athletes = []

15.times do |i|
  user = User.create!(
    email: "testuser#{i + 1}@example.com",
    password: '111111',
    password_confirmation: '111111',
    first_name: ['Иван', 'Петр', 'Алексей', 'Дмитрий', 'Сергей', 'Мария', 'Анна', 'Елена', 'Ольга', 'Наталья'].sample,
    last_name: ['Иванов', 'Петров', 'Сидоров', 'Кузнецов', 'Смирнов', 'Попов', 'Соколов', 'Лебедев', 'Козлов', 'Новиков'].sample,
  )

  athlete = Athlete.create!(
    user: user,
    name: "#{user.first_name} #{user.last_name}",
    male: [true, false].sample,
    event: event,
    stats: {
      'count' => rand(1..50),
      'volunteering_count' => rand(0..10),
      'h_index' => rand(1..15),
    },
  )

  test_athletes << athlete
  puts "  👤 Создан: #{athlete.name}"
end

# Создание тестовой активности (забега)
activity = Activity.create!(
  event: event,
  date: Date.current.saturday? ? Date.current : Date.tomorrow.prev_week(:saturday),
  published: true,
)

puts "✅ Активность создана на дату: #{activity.date}"

# Создание результатов для всех тестовых атлетов
test_athletes.each_with_index do |athlete, index|
  # Генерация случайного времени (от 15 до 45 минут)
  minutes = rand(15..45)
  seconds = rand(0..59)
  
  Result.create!(
    activity: activity,
    athlete: athlete,
    position: index + 1,
    total_time: Result.total_time(0, minutes, seconds),
    personal_best: [true, false].sample,
    first_run: index == 0 && rand > 0.8,
  )
end

puts "✅ Создано #{test_athletes.count} результатов"

# Создание нескольких волонтеров
3.times do |i|
  Volunteer.create!(
    activity: activity,
    athlete: test_athletes[i],
    role: ['director', 'timekeeper', 'marshal'].sample,
    comment: ['Отличная работа!', 'Помогал на финише', 'Сканировал баркоды'].sample,
  )
end

puts "✅ Создано 3 волонтера"

puts "\n🎉 Готово! Тестовые данные созданы."
puts "📊 Проверить результаты можно по адресу: /events/#{event.code_name}"
puts "\n⚠️  ВАЖНО: Для удаления тестовых данных выполните:"
puts "   Activity.find(#{activity.id}).destroy"
puts "   Event.find(#{event.id}).destroy"
puts "   User.where(email: ['testuser1@example.com', ...]).destroy_all"
