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
  end

  private

  def counters(model:, table:)
    model
      .published
      .where(athlete_id: @activity.send(table).select(:athlete_id), activity: { date: ..@activity.date })
      .group(:athlete_id)
      .count
  end
end
