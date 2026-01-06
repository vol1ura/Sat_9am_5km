# frozen_string_literal: true

namespace :notification do
  desc 'Notify new runners'
  task invite_newbies: :environment do
    athlete_ids =
      Result
        .published
        .group(:athlete_id)
        .having("MIN(activity.date) #{1.week.ago.to_date.all_week.to_fs(:db)}")
        .select(:athlete_id)
    User.joins(:athlete).where(athlete: { id: athlete_ids }).find_each do |user|
      Telegram::Notification::User::NewRunner.call(user)
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
end
