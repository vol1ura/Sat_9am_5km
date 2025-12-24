# frozen_string_literal: true

namespace :notification do
  desc 'Notify new runners'
  task invite_newbies: :environment do
    athlete_ids =
      Result
        .published
        .group(:athlete_id)
        .having("MIN(activities.date) #{1.week.ago.to_date.all_week.to_fs(:db)}")
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

  desc 'Set notification jobs for volunteers before activity'
  task volunteers: :environment do
    Event.find_each do |event|
      notification_time = event.timezone_object.now.change(hour: 18)
      Telegram::Notification::VolunteerJob.set(wait_until: notification_time).perform_later(event.id)
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

    User.where(role: %i[super_admin admin]).find_each { |user| Telegram::Notification::User::Message.call(user, message) }
  end

  desc 'Notify about incorrect activities'
  task incorrect_activities: :environment do
    incorrect_activities = Activity.published.reject(&:correct?)

    incorrect_activities.each do |activity|
      message = "*Warning!* Protocol of activity ID=#{activity.id} at #{activity.date} is incorrect.\nPlease fix it."
      [
        *User.where(role: %i[super_admin admin]),
        *User.protocol_responsible(activity),
      ]
        .compact
        .each { |user| Telegram::Notification::User::Message.call(user, message) }
    end
  end

  desc 'Notify about incorrect running volunteers'
  task incorrect_running_volunteers: :environment do
    incorrect_running_volunteers = Activity.published.where(date: 2.weeks.ago..).map(&:incorrect_running_volunteers).flatten

    incorrect_running_volunteers.each do |volunteer|
      message = <<~MESSAGE
        *Warning!* Activity ID=#{volunteer.activity_id} at #{volunteer.activity.date} has running volunteer
        *#{volunteer.athlete.name}* (ID=#{volunteer.athlete.code})
        without result in protocol. Please fix it.
      MESSAGE
      [
        *User.where(role: %i[super_admin admin]),
        *User.protocol_responsible(volunteer.activity),
        volunteer.athlete.user,
      ]
        .compact
        .each { |user| Telegram::Notification::User::Message.call(user, message) }
    end
  end
end
