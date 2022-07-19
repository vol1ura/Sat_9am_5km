# frozen_string_literal: true

namespace :badges do
  desc 'Award participants of activity'
  task :award_participants, %i[activity_id badge_id] => :environment do |_, args|
    activity = Activity.find args.activity_id
    badge = Badge.find args.badge_id

    activity.athletes.each do |athlete|
      athlete.trophies << Trophy.new(badge: badge, date: activity.date)
      Rails.logger.warn(athlete.errors.inspect) unless athlete.save
    end

    activity.volunteers.each do |vol|
      vol.athlete.trophies << Trophy.new(badge: badge, date: activity.date)
      Rails.logger.warn(vol.athlete.errors.inspect) unless vol.athlete.save
    end
  end
end
