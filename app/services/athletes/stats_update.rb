# frozen_string_literal: true

module Athletes
  class StatsUpdate < ApplicationService
    def initialize(athlete)
      @athlete = athlete
    end

    def call
      process_results
      process_volunteering
      @athlete.save!
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
        'longest_streak' => longest_weekly_streak(published_results.pluck(:date)),
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
        'longest_streak' => longest_weekly_streak(published_volunteering.pluck(:date)),
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

    def longest_weekly_streak(dates)
      return 0 if dates.empty?

      week_counts = Hash.new(0)
      dates.each { |date| week_counts[date.to_date.beginning_of_week(:monday)] += 1 }

      longest = 0
      current = 0
      previous_week = nil

      week_counts.keys.sort.each do |week_start|
        if previous_week && week_start == previous_week + 7
          current += week_counts[week_start]
        else
          current = week_counts[week_start]
        end
        longest = [longest, current].max
        previous_week = week_start
      end

      longest
    end
  end
end
