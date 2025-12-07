# frozen_string_literal: true

namespace :test_data do
  desc 'Create test statistics data for last Saturday'
  task create_stats: :environment do
    last_saturday = Date.parse('2025-11-30')

    country = Country.find_or_create_by!(code: 'ru')

    event = Event.find_or_create_by!(code_name: 'test_moscow') do |e|
      e.name = 'Тестовый забег Москва'
      e.town = 'Москва'
      e.place = 'Тестовый парк'
      e.timezone = 'Europe/Moscow'
      e.country = country
      e.active = true
    end

    activity = Activity.find_or_create_by!(event: event, date: last_saturday) do |a|
      a.published = true
    end

    puts "Creating test data for #{last_saturday}..."

    existing_results = 15
    15.times do |i|
      athlete = Athlete.find_or_create_by!(parkrun_code: 1000000 + i) do |a|
        a.name = "Тестовый участник #{i + 1}"
        a.male = i.even?
        a.event = event
      end

      Result.find_or_create_by!(activity: activity, athlete: athlete) do |r|
        r.position = i + 1
        r.total_time = Time.zone.local(2000, 1, 1, 0, 20 + i, rand(60))
      end

      old_activity = Activity.find_or_create_by!(
        event: event,
        date: last_saturday - 14.days
      ) do |a|
        a.published = true
      end

      Result.find_or_create_by!(activity: old_activity, athlete: athlete) do |r|
        r.position = i + 1
        r.total_time = Time.zone.local(2000, 1, 1, 0, 21 + i, rand(60))
      end
    end

    newcomer_count = 5
    5.times do |i|
      athlete = Athlete.find_or_create_by!(parkrun_code: 2000000 + i) do |a|
        a.name = "Новичок #{i + 1}"
        a.male = i.odd?
        a.event = event
      end

      Result.find_or_create_by!(activity: activity, athlete: athlete) do |r|
        r.position = existing_results + i + 1
        r.total_time = Time.zone.local(2000, 1, 1, 0, 30 + i, rand(60))
      end
    end

    3.times do |i|
      athlete = Athlete.find_or_create_by!(parkrun_code: 3000000 + i) do |a|
        a.name = "Волонтёр #{i + 1}"
        a.male = true
        a.event = event
      end

      Volunteer.find_or_create_by!(activity: activity, athlete: athlete) do |v|
        v.role = %w[timer scanner tokens][i]
      end
    end

    total = activity.participants.count
    puts "✓ Created activity for #{last_saturday}"
    puts "✓ Total participants: #{total}"
    puts "✓ Runners: #{activity.results.count}"
    puts "✓ Volunteers: #{activity.volunteers.count}"
    puts "✓ Newcomers: #{newcomer_count}"
    puts "✓ Percentage: #{(newcomer_count.to_f / total * 100).round(1)}%"
  end
end
