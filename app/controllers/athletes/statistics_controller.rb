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
        .group('events.id, events.name, events.code_name')
        .select('events.name as event_name, events.code_name as event_code_name,
                COUNT(results.id) as results_count,
                MIN(results.position) as best_position, MIN(results.total_time) as best_time')
        .order('events.visible_order')

      @volunteering_by_event = athlete_volunteering
        .joins(activity: :event)
        .group('events.id, events.name, events.code_name')
        .select('events.name as event_name, events.code_name as event_code_name,
                COUNT(volunteers.id) as vol_count,
                  COUNT(DISTINCT volunteers.role) as unique_roles_count')
        .order('events.visible_order')
    end

    def total_trophies
      @total_trophies = @athlete.trophies.size
    end

    def goals
      @recent_since = 6.days.ago.to_date
      assign_goal_thresholds
      assign_goal_progress
      assign_bingo_progress
    end

    def followers
      @friendships_hash = current_user&.athlete&.friendships&.pluck(:friend_id, :id).to_h
    end

    def friends
      @friendships_hash = current_user&.athlete&.friendships&.pluck(:friend_id, :id).to_h
    end

    def volunteering_chart
      @volunteering = athlete_volunteering
      @total_results = athlete_results.size
      @role_counts = @volunteering.group(:role).order(count_all: :desc).count
      @h_index = @role_counts.values.map.with_index.take_while { |count, idx| count > idx }.size
      @h_index_target = @h_index + 1
      @h_index_missing_roles = [@h_index_target - @role_counts.size, 0].max
    end

    private

    def set_athlete
      @athlete = Athlete.find(params.expect(:athlete_id))
    end

    def athlete_results
      @athlete_results ||= @athlete.results.published
    end

    def athlete_volunteering
      @athlete_volunteering ||= @athlete.volunteering.unscope(:order)
    end

    def assign_goal_thresholds
      participating = Badge.thresholds_for(:participating)
      @run_thresholds = participating[:result]
      @vol_thresholds = participating[:volunteer]
      @event_thresholds = Badge.thresholds_for(:tourist).values.flatten.uniq.sort
    end

    def assign_goal_progress
      first_event_dates = @athlete.first_event_visit_dates
      @total_results = athlete_results.size
      @total_vol = athlete_volunteering.count
      @events_count = first_event_dates.size
      @recent_runs = athlete_results.exists?(activity: { date: @recent_since.. })
      @recent_vol = athlete_volunteering.exists?(activity: { date: @recent_since.. })
      @recent_events = first_event_dates.any? { |_event_id, date| date >= @recent_since }
    end

    def assign_bingo_progress
      @bingo_by_second = @athlete.first_finish_seconds
      @recent_bingo = @bingo_by_second.any? { |_second, result| result.date >= @recent_since }
    end
  end
end
