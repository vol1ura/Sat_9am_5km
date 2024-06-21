# frozen_string_literal: true

module Athletes
  class StatsUpdate < ApplicationService
    def initialize(athlete)
      @athlete = athlete
    end

    def call
      process_results
      process_volunteering

      @athlete.without_auditing do
        @athlete.save!
      end
    end

    private

    def process_results
      published_results = @athlete.results.published
      results_count = published_results.size
      return if results_count.zero?

      (@athlete.stats['results'] ||= {}).merge!(
        'count' => results_count,
        'h_index' => h_index(published_results, :event_id),
        'uniq_events' => uniq_events(published_results),
        'trophies' => trophies_count,
      )
    end

    def process_volunteering
      published_volunteering = @athlete.volunteering.unscope(:order)
      volunteering_count = published_volunteering.size
      return if volunteering_count.zero?

      (@athlete.stats['volunteers'] ||= {}).merge!(
        'count' => volunteering_count,
        'h_index' => h_index(published_volunteering, :role),
        'uniq_events' => uniq_events(published_volunteering),
        'trophies' => trophies_count,
      )
    end

    def uniq_events(dataset)
      dataset.select(:event_id).distinct.count
    end

    def h_index(dataset, param)
      dataset.group(param).order(count_all: :desc).count.values.map.with_index.take_while { |count, idx| count > idx }.size
    end

    def trophies_count
      @trophies_count ||= @athlete.trophies.count
    end
  end
end
