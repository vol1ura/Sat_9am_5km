# frozen_string_literal: true

module Metrics
  class LocationHealthCalculator < ApplicationService
    def initialize(event)
      @event = event
    end

    def call
      return 0 unless @event.active?

      factors = []

      factors << calculate_activity_frequency_factor
      factors << calculate_volunteer_consistency_factor
      factors << calculate_athlete_retention_factor
      factors << calculate_results_quality_factor

      factors.sum.to_f / factors.size
    end

    private

    def calculate_activity_frequency_factor
      six_months_ago = Date.current - 6.months
      recent_activities = Activity.published.where(event: @event, date: six_months_ago..).count
      (recent_activities.to_f / 26.0 * 100).clamp(0, 100)
    end

    def calculate_volunteer_consistency_factor
      recent_volunteers = Volunteer.joins(:activity)
        .where(activity: { event: @event, published: true, date: (Date.current - 6.months).. })
        .distinct.count(:athlete_id)
      total_volunteers = Volunteer.joins(:activity)
        .where(activity: { event: @event, published: true })
        .distinct.count(:athlete_id)

      return 0 if total_volunteers.zero?

      (recent_volunteers.to_f / total_volunteers * 100).clamp(0, 100)
    end

    def calculate_athlete_retention_factor
      six_months_ago = Date.current - 6.months
      total_athletes = @event.athletes.count

      recent_athletes = Result.joins(:activity)
        .where(activity: { event: @event, published: true, date: six_months_ago.. })
        .distinct.count(:athlete_id)

      returning_athletes = Result.joins(:activity)
        .where(activity: { event: @event, published: true })
        .group(:athlete_id)
        .having('COUNT(*) > 1')
        .distinct.count(:athlete_id)

      return 0 if total_athletes.zero?

      (
        (recent_athletes.to_f / total_athletes * 50) +
        (returning_athletes.to_f / total_athletes * 50)
      ).clamp(0, 100)
    end

    def calculate_results_quality_factor
      recent_results = Result.joins(:activity)
        .includes(:athlete)
        .where(activity: { event: @event, published: true, date: (Date.current - 3.months).. })

      total = recent_results.count
      return 100 if total.zero?

      incorrect = recent_results.count { |result| !result.correct? }

      (1.0 - (incorrect.to_f / total)) * 100
    end
  end
end
