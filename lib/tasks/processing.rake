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

    rows =
      Volunteer
        .joins(:athlete, activity: :event)
        .joins(<<~SQL.squish)
          LEFT JOIN results ON results.activity_id = volunteers.activity_id
            AND results.athlete_id = volunteers.athlete_id
        SQL
        .published
        .pacemaker_role
        .pluck(
          Arel.sql(
            '(SELECT COUNT(*) FROM activities a ' \
            'WHERE a.event_id = activity.event_id AND a.published = TRUE AND a.date <= activity.date)',
          ),
          'activity.date',
          'event.name',
          'athlete.name',
          'volunteers.athlete_id',
          'results.total_time',
          'volunteers.comment',
        )
    file = CSV.generate(headers: true) do |csv|
      csv << %w[N Date Event Name ID Time Comment]
      rows.each do |row|
        row[5] = Result.time_string row[5]
        csv << row
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
