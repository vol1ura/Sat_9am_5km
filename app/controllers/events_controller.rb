# frozen_string_literal: true

class EventsController < ApplicationController
  def show
    @event = Event.find_by!(code_name: params[:code_name])
    @total_activities = @event.activities.published.size
    @count_volunteers = Volunteer.joins(:activity).where(activity: { event: @event }).group(:activity).count
  end
end
