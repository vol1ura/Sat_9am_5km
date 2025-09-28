# frozen_string_literal: true

namespace :notification do
  desc 'Notify new runners'
  task invite_newbies: :environment do
    last_week_first_runs = Result
      .published
      .where(activity: { date: Date.current.prev_week(:saturday) }, first_run: true)
      .select(:athlete_id)
    athlete_ids = Result
      .where(athlete_id: last_week_first_runs)
      .group(:athlete_id)
      .having('COUNT(*) = 1')
      .select(:athlete_id)
    User.joins(:athlete).where(athlete: { id: athlete_ids }).find_each do |user|
      Telegram::Notification::User::NewRunner.call(user)
    end
  end

  desc 'Notify about breaking time badge expiration'
  task breaking_time_badges_expiration: :environment do
    threshold_date = BreakingTimeAwardingJob::EXPIRATION_PERIOD.ago.to_date + 1.week
    Trophy.where(badge: Badge.breaking_kind, date: ..threshold_date).find_each do |trophy|
      Telegram::Notification::Badge::BreakingTimeExpiration.call(trophy)
    end
  end

  desc 'Notify about rage badge expiration'
  task rage_badges_expiration: :environment do
    Trophy.where(badge: Badge.rage_kind, date: Date.current.prev_week(:saturday)).find_each do |trophy|
      Telegram::Notification::Badge::RageExpiration.call(trophy)
    end
  end

  desc 'Notify volunteers before activity'
  task volunteers: :environment do
    Event.find_each do |event|
      time_current = event.timezone_object.now
      closest_friday = time_current.friday? ? time_current : time_current.next_occurring(:friday)
      Telegram::Notification::VolunteerJob.set(wait_until: closest_friday.change(hour: 18)).perform_later(event.id)
    end
  end

  desc 'Notify about doubled results'
  task doubled_results: :environment do
    doubled_results =
      Result
        .published
        .where.not(athlete_id: nil)
        .where.not('EXTRACT(MONTH FROM date) = 1 AND EXTRACT(DAY FROM date) = 1')
        .group(:athlete_id, :date).having('COUNT(results.id) >= 2')
        .select(:athlete_id, :date)
    next if doubled_results.load.empty?

    message =
      "Athletes with doubled results:\n#{doubled_results.map { |r| "ID=#{r[:athlete_id]} on #{r[:date]}" }.join("\n")}"

    User.super_admin.find_each { |user| Telegram::Notification::User::Message.call(user, message) }
  end

  desc 'Notify about incorrect activities'
  task incorrect_activities: :environment do
    incorrect_activities = Activity.published.reject(&:correct?)
    next if incorrect_activities.empty?

    message = "Incorrect activities:\n#{incorrect_activities.map { |a| "ID=#{a.id} on #{a.date}" }.join("\n")}"

    User.super_admin.find_each { |user| Telegram::Notification::User::Message.call(user, message) }
  end
end
