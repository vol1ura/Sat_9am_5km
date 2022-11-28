# frozen_string_literal: true

class ActivitiesController < ApplicationController
  def index
    today = Date.current
    date_since = today.sunday? ? today.monday : today.prev_week
    @activities = Activity.published.includes(:event).where(date: date_since..).order('activities.date DESC', 'events.name')
    @results_count = Result.where(activity: @activities.unscope(:order, :includes)).group(:activity_id).count
  end

  def show
    @activity = Activity.find(params[:id])
    @results_count = Result.joins(athlete: :activities)
                           .where(athlete: { activities: @activity })
                           .published
                           .group(:athlete)
                           .count
    @volunteering_count = Volunteer.joins(:activity, athlete: :activities)
                                   .where(activity: { published: true }, athlete: { activities: @activity })
                                   .group(:athlete)
                                   .count
    @results = @activity.results.includes(athlete: :club).order(:position)
  end
end
