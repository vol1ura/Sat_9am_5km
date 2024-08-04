# frozen_string_literal: true

class ResultsProcessingJob < ApplicationJob
  queue_as :critical

  def perform(activity_id)
    activity = Activity.published.find activity_id

    activity.results.where('personal_best = TRUE OR first_run = TRUE').update_all(personal_best: false, first_run: false) # rubocop:disable Rails/SkipsModelValidations

    activity.results.where.not(athlete: nil).includes(:athlete).find_each do |result|
      past_results =
        result.athlete.results.published.where(activity: { date: ...activity.date }).pluck(:total_time, :event_id)

      next result.update!(personal_best: true, first_run: true) if past_results.empty?

      result.update!(personal_best: true) if past_results.map(&:first).min > result.total_time
      result.update!(first_run: true) unless past_results.map(&:last).include?(activity.event_id)
    end
  end
end
