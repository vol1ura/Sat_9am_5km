# frozen_string_literal: true

module Athletes
  class StatsUpdate < ApplicationService
    def initialize(athlete)
      @athlete = athlete
    end

    def call
      @athlete.without_auditing do
        @athlete.update!(stats:)
      end
    end

    private

    def stats
      data = {}
      if (results_count = published_results.size).positive?
        data[:results] = {
          count: results_count,
          h_index: h_index(published_results, :event_id),
          uniq_events: uniq_events(published_results),
        }
      end
      if (volunteering_count = published_volunteering.size).positive?
        data[:volunteers] = {
          count: volunteering_count,
          h_index: h_index(published_volunteering, :role),
          uniq_events: uniq_events(published_volunteering),
        }
      end

      data
    end

    def published_results
      @published_results ||= @athlete.results.published
    end

    def published_volunteering
      @published_volunteering ||= @athlete.volunteering.unscope(:order)
    end

    def uniq_events(dataset)
      dataset.select(:event_id).distinct.count
    end

    def h_index(dataset, param)
      dataset.group(param).order(count_all: :desc).count.values.map.with_index.take_while { |count, idx| count > idx }.size
    end
  end
end
