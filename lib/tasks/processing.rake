# frozen_string_literal: true

namespace :processing do
  desc 'Last week processing'
  task results: :environment do
    Activity.published.where(date: Date.current.all_week).find_each do |activity|
      ResultsProcessingJob.perform_now(activity.id)
    end
  end

  desc 'Awarding for last week'
  task awarding: :environment do
    Activity.published.where(date: Date.current.all_week).find_each do |activity|
      AthletesAwardingJob.perform_now(activity.id)
    end
    BreakingTimeAwardingJob.perform_now
  end

  desc 'Award by badge of home participating kind'
  task home_badge_awarding: :environment do
    HomeBadgeAwardingJob.perform_now
  end

  desc 'create Parkzhrun activity'
  task parkzhrun: :environment do
    ParkzhrunMailer.success.deliver_later if Parkzhrun::ActivityCreator.call(1.day.ago)
  rescue StandardError => e
    Rollbar.error e
    ParkzhrunMailer.error.deliver_later
  end
end
