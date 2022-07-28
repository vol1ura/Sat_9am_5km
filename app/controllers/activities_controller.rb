# frozen_string_literal: true

class ActivitiesController < ApplicationController
  def index
    today = Date.current
    date_since = today.sunday? ? today.monday : today.prev_week
    @activities = Activity.published.includes(:event).where(date: date_since..).order('events.name')
  end

  def show
    @activity = Activity.find(params[:id])
    @counts = Result.joins(athlete: :activities).where(athlete: { activities: @activity }).published.group(:athlete).count
    @results = @activity.results.includes(athlete: :club).order(:position)
  end
end
