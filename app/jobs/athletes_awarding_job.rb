# frozen_string_literal: true

class AthletesAwardingJob < ApplicationJob
  queue_as :default

  def perform(activity_id)
    @activity = Activity.find activity_id
    return unless @activity.published

    [true, false].each { |male| process_event_records(male:) }

    @activity.athletes.find_each do |athlete|
      award_athlete(athlete, badge_type: 'result')
    end

    @activity.volunteers.includes(:athlete).find_each do |volunteer|
      award_athlete(volunteer.athlete, badge_type: 'volunteer')
    end
  end

  private

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def process_event_records(male:)
    best_result = @activity.results.joins(:athlete).where(athlete: { male: }).order(:position).first
    return unless best_result

    record_badge = Badge.record_kind.find_by("(info->'male')::boolean = ?", male)
    trophies = Trophy.where(badge: record_badge).where("info @@ '$.data[*].event_id == ?'", event_id)
    award_by_record_badge!(record_badge, best_result) and return if trophies.empty?

    award_best_result = false
    Trophy.transaction do
      trophies.each do |trophy|
        record_data = trophy.data.find { |d| d['event_id'] == event_id }
        record_result = Result.find(record_data['result_id'])
        next if best_result.total_time > record_result.total_time || best_result.date < record_result.date

        award_best_result ||= true
        trophy.data.delete(record_data)
        if best_result.athlete_id == record_result.athlete_id
          trophy.data << { event_id: event_id, result_id: best_result.id }
          trophy.save!
          next
        end
        trophy.destroy and next if trophy.data.empty?

        trophy.save!
      end
    end
    return if !award_best_result || trophies.exists?(athlete_id: best_result.athlete_id)

    award_by_record_badge!(record_badge, best_result)
  rescue StandardError => e
    Rollbar.error e, activity_id: @activity.id
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

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

  def event_id
    @event_id ||= @activity.event_id
  end

  def award_by_record_badge!(badge, result)
    trophy = Trophy.find_or_initialize_by(badge: badge, athlete_id: result.athlete_id)
    trophy.update!(info: { data: [{ event_id: event_id, result_id: result.id }] }) and return if trophy.data.blank?

    trophy.data.delete_if { |d| d['event_id'] == event_id }
    trophy.data << { event_id: event_id, result_id: result.id }
    trophy.save!
  end

  def rage_badge_awarding!(athlete)
    rage_badge = Badge.rage_kind.take!

    if athlete.award_by_rage_badge?
      athlete.trophies.create!(badge: rage_badge, date: activity_date) unless athlete.trophies.exists?(badge: rage_badge)
    else
      athlete.trophies.where(badge: rage_badge).destroy_all
    end
  end

  def threshold_awarding!(athlete, kind:, type:, value:)
    badges_dataset = Badge.dataset_of(kind:, type:).where("(info->'threshold')::integer <= ?", value)
    return unless (badge = badges_dataset.last) && !athlete.trophies.exists?(badge:)

    athlete.trophies.where(badge: badges_dataset.where.not(id: badge.id)).destroy_all
    athlete.trophies.create! badge: badge, date: activity_date
  end
end
