# frozen_string_literal: true

class ActivitiesController < ApplicationController
  def index
    @activities =
      Event
        .where(country_code: top_level_domain)
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
    @results_count =
      Result.published.joins(athlete: :activities).where(athlete: { activities: @activity }).group(:athlete).count
    @volunteering_count_a =
      Volunteer.published.joins(athlete: :activities).where(athlete: { activities: @activity }).group(:athlete).count
    @volunteering_count_v =
      Volunteer.published.group(:athlete).having(athlete_id: @activity.volunteers.select(:athlete_id)).count
    @results = @activity.results.includes(athlete: :club).order(:position)
  end
end
