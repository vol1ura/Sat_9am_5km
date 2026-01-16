# frozen_string_literal: true

module Athletes
  class StatisticsController < ApplicationController
    before_action :set_athlete

    def personal_bests
      @personal_bests = athlete_results.includes(activity: :event).where(personal_best: true).order(date: :desc)
    end

    def total_results; end

    def total_events
      @results_by_event = athlete_results
        .joins(activity: :event)
        .group('events.id, events.name')
        .select('events.name as event_name, COUNT(results.id) as results_count,
                MIN(results.position) as best_position, MIN(results.total_time) as best_time')
        .order('events.visible_order')

      @volunteering_by_event = @athlete
        .volunteering
        .unscope(:order)
        .joins(activity: :event)
        .group('events.id, events.name')
        .select('events.name as event_name, COUNT(volunteers.id) as vol_count,
                  COUNT(DISTINCT volunteers.role) as unique_roles_count')
        .order('events.visible_order')
    end

    def total_trophies
      @total_trophies = @athlete.trophies.size
      @total_results = athlete_results.size
      @seconds_in_results = @athlete.stats.dig('results', 'seconds') || []
    end

    def followers
      @friendships_hash = current_user&.athlete&.friendships&.pluck(:friend_id, :id).to_h
    end

    def friends
      @friendships_hash = current_user&.athlete&.friendships&.pluck(:friend_id, :id).to_h
    end

    def best_position_absolute
      best_position = athlete_results.select('MIN(results.position)')
      @pb_by_position = athlete_results.includes(activity: :event).where(position: best_position).order(date: :desc)
    end

    def volunteering_chart
      @volunteering = @athlete.volunteering.unscope(:order)
      @total_results = athlete_results.size
    end

    private

    def set_athlete
      @athlete = Athlete.find(params[:athlete_id])
    end

    def athlete_results
      @athlete_results ||= @athlete.results.published
    end
  end
end
