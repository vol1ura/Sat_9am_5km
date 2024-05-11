# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :find_event

  def show
    @total_activities = @event.activities.published.size
    @results_count = Result.published.where(activity: { event: @event }).group(:activity).count
    @volunteers_count = Volunteer.joins(:activity).where(activity: { event: @event }).group(:activity).count
  end

  def volunteering
    @activities = Activity.where(event: @event, date: Date.current..).order(:date).limit(4)
    @tg_chat = @event.contacts.find_by(contact_type: :tg_chat)
  end

  private

  def find_event
    @event = Event.find_by!(code_name: params[:code_name])
  end
end
