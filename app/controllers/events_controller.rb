# frozen_string_literal: true

class EventsController < ApplicationController
  def index
    @events = Event.all
  end

  def show
    @event = Event.find_by!(code_name: params[:code_name])
    @total_activities = @event.activities.size
  end
end
