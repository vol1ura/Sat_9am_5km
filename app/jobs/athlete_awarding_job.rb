# frozen_string_literal: true

class AthleteAwardingJob < ApplicationJob
  queue_as :default

  def perform(activity_id)
    @activity = Activity.find activity_id
    return unless @activity.published

    [true, false].each { |male| process_event_records(male:) }
    @activity.athletes.each { |athlete| award_runner(athlete) }
    @activity.volunteers.each { |volunteer| award_volunteer(volunteer.athlete) }
  end

  private

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def process_event_records(male:)
    best_result = @activity.results.joins(:athlete).where(athlete: { male: }).order(:position).first
    return unless best_result

    record_badge = Badge.record_kind.find_by("(info->'male')::boolean = ?", male)
    trophies = Trophy.where(badge: record_badge).where("info @@ '$.data[*].event_id == ?'", event_id)
    award_by_record_badge(record_badge, best_result) and return if trophies.empty?

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

    award_by_record_badge(record_badge, best_result)
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def award_runner(athlete)
    results = athlete.results.published.where(activity: { date: ..activity_date }).order('activity.date')
    threshold_awarding(athlete, :participating, 'athlete', results.size)
    events_count = results.joins(activity: :event).select('events.id').distinct.count
    threshold_awarding(athlete, :tourist, 'athlete', events_count)
    award_by_rage_badge(athlete)
    athlete.save!
  end

  def award_volunteer(athlete)
    volunteering = athlete.volunteering.where(activity: { date: ..activity_date })
    threshold_awarding(athlete, :participating, 'volunteer', volunteering.size)
    events_count = volunteering.joins(activity: :event).select('events.id').distinct.count
    threshold_awarding(athlete, :tourist, 'volunteer', events_count)
    athlete.save!
  end

  def activity_date
    @activity_date ||= @activity.date
  end

  def event_id
    @event_id ||= @activity.event_id
  end

  def award_by_record_badge(badge, result)
    trophy = Trophy.find_or_initialize_by(badge: badge, athlete_id: result.athlete_id)
    trophy.update!(info: { data: [{ event_id: event_id, result_id: result.id }] }) and return if trophy.data.blank?

    trophy.data.delete_if { |d| d['event_id'] == event_id }
    trophy.data << { event_id: event_id, result_id: result.id }
    trophy.save!
  end

  def award_by_rage_badge(athlete)
    rage_badge = Badge.rage_kind.take!

    if athlete.award_by_rage_badge?
      athlete.award_by Trophy.new(badge: rage_badge, date: activity_date)
    else
      athlete.trophies.where(badge: rage_badge).destroy_all
    end
  end

  def threshold_awarding(athlete, kind, type, value)
    badges_dataset = Badge.dataset_of(kind:, type:).where("(info->'threshold')::integer <= ?", value)
    return unless (badge = badges_dataset.last) && !athlete.trophies.exists?(badge:)

    athlete.trophies.where(badge: badges_dataset.where.not(id: badge.id)).destroy_all
    athlete.award_by Trophy.new(badge: badge, date: activity_date)
  end
end
