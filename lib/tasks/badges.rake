# frozen_string_literal: true

namespace :badges do
  desc 'Awardings for last week'
  task weekly_awarding: :environment do
    Activity.published.where(date: Date.current.all_week).find_each do |activity|
      AthleteAwardingJob.perform_now(activity.id)
    end
    BreakingTimeAwardingJob.perform_now
  end

  desc 'Notify about breaking time badge expiration'
  task notify_breaking_time_badges_expiration: :environment do
    date = BreakingTimeAwardingJob::EXPIRATION_PERIOD.months.ago.to_date + 1.week
    Trophy.where(badge: Badge.breaking_kind, date: ..date).find_each do |trophy|
      TelegramNotification::Badge::BreakingTimeExpiration.call(trophy)
    end
  end

  desc 'Notify about rage badge expiration'
  task notify_rage_badges_expiration: :environment do
    Trophy.where(badge: Badge.rage_kind, date: Date.current.prev_week(:saturday)).find_each do |trophy|
      TelegramNotification::Badge::RageExpiration.call(trophy)
    end
  end
end
