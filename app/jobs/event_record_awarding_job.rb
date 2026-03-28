# frozen_string_literal: true

class EventRecordAwardingJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    Athlete.genders.each_key { |gender| sync_event_record event_id, gender }
  end

  private

  def sync_event_record(event_id, gender)
    badge = Badge.record_kind.find_by("info->>'gender' = ?", gender)

    Trophy.transaction do
      existing = Trophy.where(badge:).where("info @@ '$.data[*].event_id == #{event_id.to_i}'").lock('FOR UPDATE').to_a

      record_results = fetch_record_results(event_id, gender)
      record_athlete_ids = record_results.map(&:athlete_id)

      purge_event_entries(existing.reject { |t| record_athlete_ids.include?(t.athlete_id) }, event_id)
      upsert_record_trophies(badge, event_id, record_results, existing)
    end
  end

  def fetch_record_results(event_id, gender)
    best_time = Result.published.joins(:athlete).where(activity: { event_id: }, athlete: { gender: }).minimum(:total_time)

    Result
      .published
      .joins(:athlete)
      .where(activity: { event_id: }, athlete: { gender: }, total_time: best_time)
      .select('DISTINCT ON (results.athlete_id) results.id, results.athlete_id')
      .order(:athlete_id, :position, :date)
  end

  def purge_event_entries(trophies, event_id)
    trophies.each do |trophy|
      trophy.data.delete_if { |d| d['event_id'] == event_id }
      trophy.data.empty? ? trophy.destroy! : trophy.save!
    end
  end

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def upsert_record_trophies(badge, event_id, record_results, existing_trophies)
    record_results.each do |result|
      trophy = existing_trophies.find { |t| t.athlete_id == result.athlete_id }
      trophy ||= Trophy.find_or_initialize_by(badge: badge, athlete_id: result.athlete_id)
      trophy.info = { data: [] } unless trophy.data
      next if trophy.data.any? { |d| d['event_id'] == event_id && d['result_id'] == result.id }

      trophy.data.delete_if { |d| d['event_id'] == event_id }
      trophy.data << { 'event_id' => event_id, 'result_id' => result.id }
      trophy.save!
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
end
