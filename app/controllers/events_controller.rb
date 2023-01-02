# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :find_event

  def show
    published_activities = @event.activities.published
    @total_activities = published_activities.size
    @results_count =
      Result
        .joins(:activity)
        .where(activity: { published: true, event_id: @event.id })
        .group(:activity)
        .count
    @volunteers_count = Volunteer.joins(:activity).where(activity: { event: @event }).group(:activity).count
  end

  def volunteering
    @activities = Activity.where(event: @event, date: Date.tomorrow..).order(:date).limit(4)
  end

  private

  def find_event
    @event = Event.find_by!(code_name: params[:code_name])
  end
end
