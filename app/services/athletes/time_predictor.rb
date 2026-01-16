# frozen_string_literal: true

module Athletes
  # Pete Riegel's formula https://www.omnicalculator.com/sports/race-predictor
  class TimePredictor < ApplicationService
    COEFFICIENTS = [10, 21.1, 42.2].index_with { |x| (x / 5)**1.08 }.freeze

    param :athlete, reader: :private

    def call
      return {} if recent_total_times.size < 3

      recent_best_time = recent_total_times.min
      COEFFICIENTS.transform_values { |coefficient| recent_best_time * coefficient }
    end

    private

    def recent_total_times
      @recent_total_times ||=
        athlete.results.published.where(activity: { date: 3.months.ago.. }).pluck(:total_time)
    end
  end
end
