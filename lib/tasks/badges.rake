# frozen_string_literal: true

namespace :badges do
  desc 'Award participants of activity'
  task :award_participants, %i[activity_id badge_id] => :environment do |_, args|
    activity = Activity.find args.activity_id
    badge = Badge.find args.badge_id

    activity.athletes.each do |athlete|
      athlete.award_by Trophy.new(badge: badge, date: activity.date)
      Rails.logger.error(athlete.errors.inspect) unless athlete.save
    end

    activity.volunteers.each do |volunteer|
      volunteer.athlete.award_by Trophy.new(badge: badge, date: activity.date)
      Rails.logger.error(volunteer.athlete.errors.inspect) unless volunteer.athlete.save
    end
  end

  desc 'Awardings for last week'
  task weekly_awarding: :environment do
    Activity.where(date: Date.current.all_week).each do |activity|
      AthleteAwardingJob.perform_now(activity.id)
    end
    BreakingTimeAwardingJob.perform_now
  end

  desc 'Notify about breaking time badge expiration'
  task notify_breaking_time_badges_expiration: :environment do
    date = BreakingTimeAwardingJob::EXPIRATION_PERIOD.months.ago - 1.week
    Trophy.where(badge: Badge.breaking_kind, date: ..date).each do |trophy|
      TelegramNotification::Badge::BreakingTimeExpiration.call(trophy)
    end
  end
end
