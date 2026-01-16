# frozen_string_literal: true

module Parkzhrun
  class ActivityCreator < ApplicationService
    def initialize(date)
      @date = date
    end

    def call
      if activity.results.exists?
        Rails.logger.warn "ParkZhrun activity on #{@date} already exists"
        return
      end

      activity.transaction do
        create_results
        create_volunteers
        activity.update!(published: true) if event.active
      end
    end

    private

    def event
      @event ||= Event.find_by!(code_name: 'parkzhrun')
    end

    def activity
      @activity ||= Activity.find_or_create_by!(date: @date, event: event)
    end

    def create_results
      Client.fetch(:results, @date).each do |result|
        Result.create!(
          position: result[:position],
          total_time: result[:total_time],
          athlete: AthleteFinder.call(result[:athlete_id]),
          activity: activity,
        )
      end
    end

    def create_volunteers
      Client.fetch(:volunteers, @date).each do |result|
        volunteer = Volunteer.new(
          role: result[:role_id].to_i,
          athlete: AthleteFinder.call(result[:volunteer_id]),
          activity: activity,
        )
        Rollbar.warn "Can't add volunteer to ParkZhrun activity", activity_id: activity.id unless volunteer.save
      end
    end
  end
end
