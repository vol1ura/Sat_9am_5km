# frozen_string_literal: true

class HomeBadgeAwardingJob < ApplicationJob
  queue_as :low

  def perform(athlete_id = nil)
    utmost_badge = Badge.new(info: { threshold: 10**10 })
    Badge::BADGE_TYPES.each do |type|
      badges_dataset = Badge.dataset_of(kind: :home_participating, type: type)
      badges_dataset.to_a.push(utmost_badge).each_cons(2) do |badge, next_badge|
        athlete_ids =
          athlete_ids_ds(type, min_events_count: badge.info['threshold'], max_events_count: next_badge.info['threshold'])
        athlete_ids = athlete_ids.where(athlete_id:) if athlete_id

        Athlete.where(id: athlete_ids).where.not(id: badge.trophies.select(:athlete_id)).find_each do |athlete|
          athlete.transaction do
            athlete.trophies.where(badge: badges_dataset.where.not(id: badge.id)).destroy_all
            athlete.trophies.create! badge: badge, date: date_of_awarding(athlete, badge)
          end
        end
      end
    end
  end

  private

  def athlete_ids_ds(type, min_events_count:, max_events_count:)
    type
      .camelize
      .constantize
      .published
      .joins(:athlete)
      .where('activity.event_id = athletes.event_id')
      .group(:athlete_id)
      .having('COUNT(*) >= ? AND COUNT(*) < ?', min_events_count, max_events_count)
      .select(:athlete_id)
  end

  def date_of_awarding(athlete, badge)
    athlete
      .send(Badge::ASSOCIATION_TYPE_MAPPING[badge.info['type']])
      .published
      .where(activity: { event: athlete.event })
      .reorder('activity.date')
      .select('activity.date')
      .offset(badge.info['threshold'].pred)
      .first[:date]
  end
end
