# frozen_string_literal: true

class AthleteAwardingJob < ApplicationJob
  queue_as :default

  def perform(activity_id)
    @activity = Activity.find activity_id
    return unless @activity.published

    [true, false].each { |male| process_event_records(male: male) }
    @activity.athletes.each { |athlete| award_runner(athlete) }
    @activity.volunteers.each { |volunteer| award_volunteer(volunteer.athlete) }
  end

  private

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def process_event_records(male:)
    best_result = @activity.results.joins(:athlete).where(athlete: { male: male }).order(:total_time, :position).first
    return unless best_result

    record_badge = Badge.record_kind.find_by("(info->'male')::boolean = ?", male)
    trophies = Trophy.where(badge: record_badge).where("info @@ '$.data[*].event_id == ?'", event_id)
    award_record_badge(record_badge, best_result) and return if trophies.empty?

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

    award_record_badge(record_badge, best_result)
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def award_runner(athlete)
    results = athlete.results.published.where(activity: { date: ..activity_date }).order('activity.date')
    Badge.participating_dataset(type: 'athlete').each do |badge|
      next if results.size < badge.info['threshold']

      athlete.award_by Trophy.new(badge: badge, date: activity_date)
    end
    events_count = results.joins(activity: :event).select('events.id').distinct.count
    tourist_badge = Badge.tourist_kind.find_by!("info->>'type' = 'athlete'")
    if events_count >= tourist_badge.info['threshold']
      athlete.award_by Trophy.new(badge: tourist_badge, date: activity_date)
    end
    award_runner_by_rage_badge(athlete, results.last(3))
    athlete.save!
  end

  def award_volunteer(athlete)
    volunteering = athlete.volunteering.where(activity: { date: ..activity_date })
    Badge.participating_dataset(type: 'volunteer').each do |badge|
      next if volunteering.size < badge.info['threshold']

      athlete.award_by Trophy.new(badge: badge, date: activity_date)
    end
    events_count = volunteering.joins(activity: :event).select('events.id').distinct.count
    tourist_badge = Badge.tourist_kind.find_by!("info->>'type' = 'volunteer'")
    if events_count >= tourist_badge.info['threshold']
      athlete.award_by Trophy.new(badge: tourist_badge, date: activity_date)
    end
    athlete.save!
  end

  def activity_date
    @activity_date ||= @activity.date
  end

  def event_id
    @event_id ||= @activity.event_id
  end

  def award_record_badge(badge, result)
    trophy = Trophy.find_or_initialize_by(badge: badge, athlete_id: result.athlete_id)
    trophy.update!(info: { data: [{ event_id: event_id, result_id: result.id }] }) and return if trophy.data.blank?

    trophy.data.delete_if { |d| d['event_id'] == event_id }
    trophy.data << { event_id: event_id, result_id: result.id }
    trophy.save!
  end

  def award_runner_by_rage_badge(athlete, last_3_results)
    return if last_3_results.size < 3

    rage_badge = Badge.rage_kind.take!
    if last_3_results.first.total_time >= last_3_results.second.total_time &&
       last_3_results.second.total_time >= last_3_results.third.total_time
      athlete.award_by Trophy.new(badge: rage_badge, date: activity_date)
    else
      athlete.trophies.where(badge: rage_badge).destroy_all
    end
  end
end
