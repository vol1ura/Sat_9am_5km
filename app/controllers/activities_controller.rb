# frozen_string_literal: true

class ActivitiesController < ApplicationController
  def index
    @activities =
      @country_events
        .unscope(:order)
        .filter_map { |event| event.activities.published.order(:date).last }
        .sort_by { |activity| [activity.date, -activity.event.visible_order.to_i] }
        .reverse
    activities_ids = @activities.map(&:id)
    @results_count = Result.where(activity_id: activities_ids).group(:activity_id).count
    @volunteers_count = Volunteer.where(activity_id: activities_ids).group(:activity_id).count
  end

  def show
    @activity = Activity.published.find(params[:id])

    @results = @activity.results.includes(athlete: :club).order(:position)

    @results_count = counters(model: Result, table: :results)
    @volunteering_r_count = counters(model: Volunteer, table: :results)
    @volunteering_v_count = counters(model: Volunteer, table: :volunteers)
    @personal_best_count = @activity.results.where(personal_best: true).size
    @first_run_count = @activity.results.where(first_run: true).size
    @volunteers = @activity.volunteers_roster.includes(:athlete)
  end

  def dashboard
    @total_results = Result.where(activity_id: weekly_activities_ids)
    @personal_bests_count = @total_results.where(personal_best: true).count
    @first_runs_count = count_newbies(model: Result, current_ds: @total_results)

    @total_volunteers = Volunteer.where(activity_id: weekly_activities_ids)
    @first_time_volunteers_count = count_newbies(model: Volunteer, current_ds: @total_volunteers)

    @gender_stats = @total_results.left_joins(:athlete).group(:gender).count
  end

  private

  def weekly_activities_ids
    @weekly_activities_ids ||=
      begin
        today = Date.current
        last_saturday = today.saturday? ? today : today.prev_occurring(:saturday)

        Activity.published.joins(:event).where(event: @country_events, date: last_saturday..).select(:id)
      end
  end

  def count_newbies(model:, current_ds:)
    model
      .published
      .where(athlete_id: current_ds.select(:athlete_id))
      .group(:athlete_id)
      .having('count(athlete_id) = 1')
      .count
      .size
  end

  def counters(model:, table:)
    model
      .published
      .where(athlete_id: @activity.send(table).select(:athlete_id), activity: { date: ..@activity.date })
      .group(:athlete_id)
      .count
  end
end
