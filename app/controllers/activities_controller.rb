# frozen_string_literal: true

class ActivitiesController < ApplicationController
  def index
    @activities = latest_activities
    activities_ids = @activities.map(&:id)
    @leader_results = leader_results_for(activities_ids)
    @results_count = Result.where(activity_id: activities_ids).group(:activity_id).count
    @volunteers_count = Volunteer.where(activity_id: activities_ids).group(:activity_id).count
  end

  def show
    @activity = Activity.find params.expect(:id)
    return redirect_to activities_path, alert: t('.not_published') unless @activity.published

    @results = @activity.results.includes(athlete: :club).order(:position)

    @results_count = counters(model: Result, table: :results)
    @volunteering_r_count = counters(model: Volunteer, table: :results)
    @volunteering_v_count = counters(model: Volunteer, table: :volunteers)
    @personal_best_count = @activity.results.where(personal_best: true).size
    @first_run_count = @activity.results.where(first_run: true).size
    @volunteers = @activity.volunteers_roster.includes(athlete: :club)
  end

  def dashboard
    @dashboard_chart = Activities::WeeklyDashboard.call(
      country_events: @country_events,
      chart: params.expect(:chart),
    )
  end

  private

  def latest_activities
    latest_per_event =
      Activity
        .published
        .where(event_id: @country_events.unscope(:order).select(:id))
        .select('DISTINCT ON (activities.event_id) activities.*')
        .reorder('activities.event_id, activities.date DESC, activities.id DESC')

    Activity
      .from("(#{latest_per_event.to_sql}) activities")
      .joins(:event)
      .includes(:event)
      .reorder(Arel.sql('activities.date DESC, COALESCE(events.visible_order, 0) ASC'))
  end

  def leader_results_for(activity_ids)
    Result
      .joins(:athlete)
      .where(activity_id: activity_ids)
      .select('DISTINCT ON (results.activity_id, athletes.gender) results.*')
      .reorder('results.activity_id, athletes.gender, results.position, results.id')
      .preload(:athlete)
      .index_by { |result| [result.activity_id, result.athlete.gender] }
  end

  def counters(model:, table:)
    model
      .published
      .where(athlete_id: @activity.send(table).select(:athlete_id), activity: { date: ..@activity.date })
      .group(:athlete_id)
      .count
  end
end
