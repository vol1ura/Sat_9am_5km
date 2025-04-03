# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :find_event, except: %i[index search map]

  def index
    @local_events = Event.in_country(top_level_domain).unscope(:order)
    @next_saturday = Date.tomorrow.next_week.prev_week(:saturday)
    @jubilee_events =
      Activity
        .where(event: @local_events.without_friends, published: true, date: ...@next_saturday)
        .group(:event).count.filter_map do |event, activities_count|
          activity_number = activities_count.next
          next unless (activity_number <= 40 && (activity_number % 10).zero?) || (activity_number % 50).zero?

          [event, activity_number]
        end
    @funrun_badges =
      Badge
        .includes(:image_attachment)
        .funrun_kind
        .where(received_date: @next_saturday)
        .where("info->>'country_code' IS NULL OR info->>'country_code' = ?", top_level_domain)
  end

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
    event_future_activities_dataset = @event.activities.where(date: Date.current..)
    @activities = event_future_activities_dataset.select(:id, :date).order(:date).limit(4).load
    @tg_chat = @event.contacts.find_by(contact_type: :tg_chat)

    activity_id = params[:activity_id].presence || @activities.first&.id
    @activity = event_future_activities_dataset.includes(volunteers: :athlete).find_by(id: activity_id) if activity_id
  end

  def map
    @events = Event.where('latitude IS NOT NULL AND longitude IS NOT NULL').map do |event|
      event.as_json(only: %i[active name slogan code_name]).merge(
        latitude: event.latitude.to_f,
        longitude: event.longitude.to_f,
      )
    end
  end

  private

  def find_event
    @event = Event.find_by!(code_name: params[:code_name]&.downcase)
  end
end
