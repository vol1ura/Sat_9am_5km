# frozen_string_literal: true

module Athletes
  class StatisticsController < ApplicationController
    before_action :set_athlete

    def personal_best_absolute
      results = @athlete.results.published
      @pb_by_time = results.where(personal_best: true).order(date: :desc)
    end

    def total_events
      results_ds = @athlete.results.published
      volunteering_ds = @athlete.volunteering.unscope(:order)

      @results_by_event = results_ds
        .joins(activity: :event)
        .group('events.id, events.name')
        .select(
          'events.name as event_name, COUNT(results.id) as results_count,
          MIN(results.position) as best_position, MIN(EXTRACT(EPOCH FROM results.total_time)) as best_time',
        )
        .order('events.visible_order')

      @volunteering_by_event = volunteering_ds
        .joins(activity: :event)
        .group('events.id, events.name')
        .select('events.name as event_name, COUNT(volunteers.id) as vol_count')
        .order('events.visible_order')

      @total_events_count = (results_ds.distinct.pluck(:event_id) + volunteering_ds.distinct.pluck(:event_id)).uniq.count
    end

    def total_trophies
      @total_trophies = @athlete.trophies.size
      @total_results = @athlete.results.published.size
      @seconds_in_results = @athlete.stats.dig('results', 'seconds') || []
    end

    def total_results
      @total_results = @athlete.results.published.size
    end

    def followers
      @friendships_hash = current_user&.athlete&.friendships&.pluck(:friend_id, :id).to_h
    end

    def friends
      @friendships_hash = current_user&.athlete&.friendships&.pluck(:friend_id, :id).to_h
    end

    def best_position_absolute
      results = @athlete.results.published
      @best_position = results.minimum(:position)
      @pb_by_position = results.includes(activity: :event).where(position: @best_position).order(date: :desc)
    end

    private

    def set_athlete
      @athlete = Athlete.find(params[:athlete_id])
    end
  end
end
