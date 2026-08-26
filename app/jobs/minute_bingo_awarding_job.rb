# frozen_string_literal: true

class MinuteBingoAwardingJob < ApplicationJob
  queue_as :low

  def perform(activity_id = nil)
    athlete_ids = Result.published.select(:athlete_id)
    athlete_ids = athlete_ids.where(activity_id:) if activity_id
    dataset = Athlete.where.not(id: minute_bingo_badge.trophies.select(:athlete_id)).where(id: athlete_ids)

    dataset.find_each do |athlete|
      first_second_dates = athlete.results.published.group(Arel.sql('results.total_time % 60')).minimum('activity.date')
      next if first_second_dates.size != 60

      athlete.trophies.create! badge: minute_bingo_badge, date: first_second_dates.values.max
    end
  end

  private

  def minute_bingo_badge
    @minute_bingo_badge ||= Badge.minute_bingo_kind.sole
  end
end
