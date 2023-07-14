# frozen_string_literal: true

class ActivitiesController < ApplicationController
  def index
    @activities = Event.all.map { |event| event.activities.published.order(:date).last }
    @results_count = Result.where(activity_id: @activities.map(&:id)).group(:activity_id).count
  end

  def show
    @activity = Activity.find_by(id: params[:id])
    redirect_to activities_path and return unless @activity&.published

    @results_count =
      Result.joins(athlete: :activities).where(athlete: { activities: @activity }).published.group(:athlete).count
    @volunteering_count_a =
      Volunteer.joins(athlete: :activities).actual.where(athlete: { activities: @activity }).group(:athlete).count
    @volunteering_count_v =
      Volunteer.actual.group(:athlete).having(athlete_id: @activity.volunteers.select(:athlete_id)).count
    @results = @activity.results.includes(athlete: :club).order(:position)
  end
end
