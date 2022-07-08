# frozen_string_literal: true

class ActivitiesController < ApplicationController
  def index
    today = Date.current
    @activities = Activity.published.includes(:event).where('date >= ?', today.sunday? ? today.monday : today.prev_week)
  end

  def show
    @activity = Activity.find(params[:id])
  end
end
