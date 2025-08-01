# frozen_string_literal: true

module Athletes
  # Pete Riegel's formula https://www.omnicalculator.com/sports/race-predictor
  class TimePredictor < ApplicationService
    COEFFICIENTS = [10, 21.1, 42.2].index_with { |x| (x / 5)**1.08 }.freeze

    def initialize(athlete)
      @athlete = athlete
    end

    def call
      return {} if recent_results.size < 3

      best_5k_time = recent_results.minimum(:total_time)
      return {} unless best_5k_time

      calculate_predictions(best_5k_time)
    end

    private

    def recent_results
      @recent_results ||= @athlete.results.published.joins(:activity).where(activity: { date: 3.months.ago.. })
    end

    def calculate_predictions(base_time_seconds)
      base_time_in_seconds = time_to_seconds(base_time_seconds)
      COEFFICIENTS.transform_values { |coefficient| Time.zone.local(2000, 1, 1) + (base_time_in_seconds * coefficient) }
    end

    def time_to_seconds(time)
      (time.hour * 3600) + (time.min * 60) + time.sec
    end
  end
end
