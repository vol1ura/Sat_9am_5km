# frozen_string_literal: true

class ActivitiesController < ApplicationController
  def index
    today = Date.current
    @activities = Activity.published.includes(:event).where('date >= ?', today.sunday? ? today.monday : today.prev_week)
  end

  def show
    @activity = Activity.find(params[:id])
    @counts = Result.joins(athlete: :activities).where(athlete: { activities: @activity }).published.group(:athlete).count
    @results = @activity.results.includes(athlete: :club).order(:position)
  end
end
