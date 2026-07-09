# frozen_string_literal: true

module Metrics
  class LocationHealthCalculator < ApplicationService
    def call(event)
      return 0 unless event.active?

      factors = []

      factors << calculate_activity_frequency_factor(event)
      factors << calculate_volunteer_consistency_factor(event)
      factors << calculate_athlete_retention_factor(event)
      factors << calculate_results_quality_factor(event)

      factors.sum.to_f / factors.size * 100
    end

    private

    def calculate_activity_frequency_factor(event)
      six_months_ago = Date.current - 6.months
      recent_activities = Activity.published.where(event: event, date: six_months_ago..).count
      (recent_activities.to_f / 26.0 * 100).clamp(0, 100)
    end

    def calculate_volunteer_consistency_factor(event)
      recent_volunteers = Volunteer.joins(:activity)
        .where(activity: { event: event, published: true, date: (Date.current - 6.months).. })
        .distinct.count(:athlete_id)
      total_volunteers = Volunteer.joins(:activity)
        .where(activity: { event: event, published: true })
        .distinct.count(:athlete_id)

      return 0 if total_volunteers.zero?

      (recent_volunteers.to_f / total_volunteers * 100).clamp(0, 100)
    end

    def calculate_athlete_retention_factor(event)
      six_months_ago = Date.current - 6.months
      total_athletes = event.athletes.count

      recent_athletes = Result.joins(:activity)
        .where(activity: { event: event, published: true, date: six_months_ago.. })
        .distinct.count(:athlete_id)

      returning_athletes = Result.joins(:activity)
        .where(activity: { event: event, published: true })
        .group(:athlete_id)
        .having('COUNT(*) > 1')
        .distinct.count(:athlete_id)

      return 0 if total_athletes.zero?

      (
        (recent_athletes.to_f / total_athletes * 50) +
        (returning_athletes.to_f / total_athletes * 50)
      ).clamp(0, 100)
    end

    def calculate_results_quality_factor(event)
      recent_results = Result.joins(:activity)
        .where(activity: { event: event, published: true, date: (Date.current - 3.months).. })

      total = recent_results.count
      return 100 if total.zero?

      incorrect = Result.joins(:activity)
        .where(activity: { event: event, published: true })
        .where(
          'total_time IS NULL OR athlete_id IS NOT NULL AND (name IS NULL OR gender IS NULL)',
        ).count

      (1.0 - (incorrect.to_f / total)) * 100
    end
  end
end
