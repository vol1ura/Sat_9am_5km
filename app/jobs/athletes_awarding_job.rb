# frozen_string_literal: true

class AthletesAwardingJob < ApplicationJob
  queue_as :default

  def perform(activity_id)
    @activity = Activity.published.find activity_id

    @activity.athletes.includes(:event).find_each do |athlete|
      award_athlete(athlete, badge_type: 'result')
    end

    @activity.volunteers.includes(athlete: :event).find_each do |volunteer|
      award_athlete(volunteer.athlete, badge_type: 'volunteer')
    end

    award_by_jubilee_participating_kind_badges
  end

  private

  def award_athlete(athlete, badge_type:)
    dataset =
      athlete
        .send(Badge::ASSOCIATION_TYPE_MAPPING[badge_type])
        .published
        .where(activity: { date: ..activity_date })

    threshold_awarding!(athlete, kind: :participating, type: badge_type, value: dataset.size)

    home_dataset = dataset.where(activity: { event: athlete.event })
    threshold_awarding!(athlete, kind: :home_participating, type: badge_type, value: home_dataset.size)

    events_count = dataset.joins(activity: :event).select('events.id').distinct.count
    threshold_awarding!(athlete, kind: :tourist, type: badge_type, value: events_count)

    rage_badge_awarding!(athlete) if badge_type == 'result'
  rescue StandardError => e
    Rollbar.error e, activity_id: @activity.id, athlete_id: athlete.id
  end

  def activity_date
    @activity_date ||= @activity.date
  end

  def rage_badge
    @rage_badge ||= Badge.rage_kind.sole
  end

  def rage_badge_awarding!(athlete)
    if athlete.award_by_rage_badge?
      athlete.trophies.create!(badge: rage_badge, date: activity_date) unless athlete.trophies.exists?(badge: rage_badge)
    else
      athlete.trophies.where(badge: rage_badge).destroy_all
    end
  end

  def threshold_awarding!(athlete, kind:, type:, value:)
    badges_dataset = Badge.dataset_of(kind:, type:)
    deserved_badges = badges_dataset.where("(info->'threshold')::integer <= ?", value)
    return unless (badge = deserved_badges.last)
    return if athlete.trophies.exists?(badge:)

    future_badges = badges_dataset.where("(info->'threshold')::integer > ?", value).unscope(:order)
    return if athlete.trophies.exists?(badge: future_badges)

    athlete.transaction do
      athlete.trophies.where(badge: badges_dataset.excluding(badge)).destroy_all
      athlete.trophies.create! badge: badge, date: activity_date
    end
  end

  def award_by_jubilee_participating_kind_badges
    return unless (badge = Badge.jubilee_participating_kind.find_by("(info->'threshold')::integer = ?", @activity.number))

    FunrunAwardingJob.perform_later @activity.id, badge.id
  end
end
