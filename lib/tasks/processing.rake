# frozen_string_literal: true

namespace :processing do
  desc 'create Parkzhrun activity'
  task parkzhrun: :environment do
    Parkzhrun::ActivityCreator.call(1.day.ago.strftime('%Y-%m-%d'))
  rescue StandardError => e
    Rollbar.error e
    NotificationMailer.parkzhrun_error.deliver_later
  end

  desc 'Compress user images'
  task compress_user_images: :environment do
    User.joins(:image_attachment).find_each do |user|
      Users::ImageCompressor.call(user)
    end
  end

  desc 'Send pacemakers report for the last week'
  task :send_pacemakers_report, [:telegram_id] => :environment do |_t, args|
    require 'csv'

    volunteers =
      Volunteer
        .published
        .where(activity: { date: 1.week.ago.all_week }, role: :pacemaker)
        .includes(:athlete, activity: :event)
        .all
    results =
      Result
        .where(activity_id: volunteers.pluck(:activity_id), athlete_id: volunteers.pluck(:athlete_id))
        .pluck(:athlete_id, :total_time)
        .to_h
        .transform_values { Result.time_string it }
    file = CSV.generate(headers: true) do |csv|
      csv << %w[N Date Event Name ID Time Comment]
      volunteers.each do |v|
        csv << [v.activity.number, v.date, v.activity.event.name, v.name, v.athlete_id, results[v.athlete_id], v.comment]
      end
    end

    Telegram::Bot.call(
      'sendDocument',
      form_data: [
        ['document', file, { filename: 'pacemakers_report.csv', content_type: 'text/csv' }],
        ['caption', 'Pacemakers report'],
        ['chat_id', args[:telegram_id]],
      ],
    )
  end

  desc 'Block by IP address'
  task :block_by_ip_address, [:ip_address] => :environment do |_t, args|
    cache_prefix = Rack::Attack.cache.prefix
    cache_suffix = "scraper:#{args[:ip_address]}"
    Rack::Attack.cache.store.write("#{cache_prefix}:allow2ban:ban:#{cache_suffix}", true, expires_in: 1.week)

    puts "IP address #{args[:ip_address]} blocked"
  end
end
