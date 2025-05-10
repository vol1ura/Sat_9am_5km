# frozen_string_literal: true

namespace :processing do
  desc 'Last week processing'
  task results: :environment do
    Activity.published.where(date: Date.current.all_week).find_each do |activity|
      ResultsProcessingJob.perform_now(activity.id)
    end
    [Result, Volunteer].each do |model|
      model
        .published
        .where(activity: { date: ...Date.current.prev_week(:saturday) }, informed: false)
        .update_all(informed: true) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  desc 'Awarding for last week'
  task awarding: :environment do
    Activity.published.where(date: Date.current.all_week).find_each do |activity|
      AthletesAwardingJob.perform_now(activity.id)
      FivePlusAwardingJob.perform_now(activity.id, with_expiration: true)
    end
    BreakingTimeAwardingJob.perform_now
  end

  desc 'Award by badge of home participating kind'
  task home_badge_awarding: :environment do
    HomeBadgeAwardingJob.perform_now
  end

  desc 'Set awarding dates for 5+ trophies'
  task set_five_plus_trophy_dates: :environment do
    initial_date = Date.current.saturday? ? Date.current : Date.tomorrow.prev_week(:saturday)
    Badge.five_plus_kind.sole.trophies.includes(:athlete).find_each do |trophy|
      res_dates = trophy.athlete.results.published.pluck(:date)
      vol_dates = trophy.athlete.volunteering.unscope(:order).pluck(:date)
      dates = (res_dates | vol_dates).uniq
      5.upto(dates.size) do |k|
        date = initial_date - k.weeks
        next if dates.include?(date) && k != dates.size

        trophy.update!(date: date + 5.weeks) and break
      end
    end
  end

  desc 'create Parkzhrun activity'
  task parkzhrun: :environment do
    ParkzhrunMailer.success.deliver_later if Parkzhrun::ActivityCreator.call(1.day.ago.strftime('%Y-%m-%d'))
  rescue StandardError => e
    Rollbar.error e
    ParkzhrunMailer.error.deliver_later
  end

  desc 'Purges unattached Active Storage blobs'
  task purge_unattached_files: :environment do
    ActiveStorage::Blob.unattached.where(created_at: ..2.days.ago).find_each(&:purge_later)
  end

  desc 'Compress user images'
  task compress_user_images: :environment do
    User.joins(:image_attachment).find_each do |user|
      Users::ImageCompressor.call(user)
    end
  end
end
