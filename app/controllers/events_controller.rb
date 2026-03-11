# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :find_event, except: %i[index search]

  def index
    @events = Event.all
    return if params[:all]

    @events = @events.in_country(top_level_domain).includes(:summer_image_attachment, :winter_image_attachment)
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

    results_dataset = Result.published.where(activity: { event: @event })
    @results_count = results_dataset.group(:activity).count
    @uniq_athletes_count = results_dataset.select(:athlete_id).distinct.count

    volunteers_dataset = Volunteer.published.where(activity: { event: @event })
    @volunteers_count = volunteers_dataset.group(:activity).count
    @uniq_volunteers_count = volunteers_dataset.select(:athlete_id).distinct.count

    @almost_jubilee_by_results = @event.almost_jubilee_athletes_dataset 'results'
    @almost_jubilee_by_volunteers = @event.almost_jubilee_athletes_dataset 'volunteers'

    @first_male_by_activity_id = leader_results(gender: :male)
    @first_female_by_activity_id = leader_results(gender: :female)
  end

  def volunteering
    event_future_activities_dataset = @event.activities.unpublished.where(date: Date.current..)
    @activities = event_future_activities_dataset.select(:id, :date).order(:date).limit(4).load
    @tg_chat = @event.contacts.find_by(contact_type: :tg_chat)

    activity_id = params[:activity_id] || @activities.first&.id
    @activity = event_future_activities_dataset.find_by(id: activity_id) if activity_id
  end

  def live; end

  private

  def find_event
    @event = Event.find_by!(code_name: params[:code_name]&.downcase)
  end

  def leader_results(gender:)
    Result
      .published
      .joins(:athlete)
      .where(activity: { event_id: @event.id }, athlete: { gender: })
      .select('DISTINCT ON (results.activity_id) results.*')
      .order('results.activity_id, results.position')
      .preload(:athlete)
      .index_by(&:activity_id)
  end
end
