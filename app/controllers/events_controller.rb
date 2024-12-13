# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :find_event, except: :search

  def search
    @events =
      Event
        .in_country(top_level_domain)
        .without_friends
        .where('name ILIKE ?', "#{params[:q]}%")
        .page(params[:page])
        .per(20)
    render turbo_stream: helpers.async_combobox_options(@events, next_page: @events.last_page? ? nil : @events.next_page)
  end

  def show
    @total_activities = @event.activities.published.size
    @results_count = Result.published.where(activity: { event: @event }).group(:activity).count
    @volunteers_count = Volunteer.published.where(activity: { event: @event }).group(:activity).count
    @uniq_athletes_count = Result.published.where(activity: { event: @event }).select(:athlete_id).distinct.count
    @uniq_volunteers_count = Volunteer.published.where(activity: { event: @event }).select(:athlete_id).distinct.count
    @almost_jubilee_by_results = @event.almost_jubilee_athletes_dataset 'results'
    @almost_jubilee_by_volunteers = @event.almost_jubilee_athletes_dataset 'volunteers'
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
