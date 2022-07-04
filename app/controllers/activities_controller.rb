# frozen_string_literal: true

class ActivitiesController < ApplicationController
  def index
    @activities = Activity.published.includes(:event)
  end

  def show
    @activity = Activity.find(params[:id])
  end
end
