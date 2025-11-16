# frozen_string_literal: true

class MinuteBingoAwardingJob < ApplicationJob
  queue_as :low

  ALL_SECONDS = 60.times.to_a.freeze

  def perform(activity_id = nil)
    athlete_ids = Result.published.select(:athlete_id)
    athlete_ids = athlete_ids.where(activity_id:) if activity_id
    dataset = Athlete.where.not(id: Trophy.where(badge: minute_bingo_badge).select(:athlete_id)).where(id: athlete_ids)

    dataset.find_each do |athlete|
      seconds = []
      athlete.results.published.order(:date).pluck(:total_time, :date).each do |total_time, date|
        seconds.push(total_time.sec)
        if (ALL_SECONDS - seconds).empty?
          athlete.trophies.create! badge: minute_bingo_badge, date: date
          break
        end
      end
      seconds = seconds.uniq.sort
      next if athlete.stats.dig('results', 'seconds') == seconds

      athlete.update!(stats: athlete.stats.deep_merge('results' => { 'seconds' => seconds }))
    end
  end

  private

  def minute_bingo_badge
    @minute_bingo_badge ||= Badge.minute_bingo_kind.sole
  end
end
