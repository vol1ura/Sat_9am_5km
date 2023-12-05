# frozen_string_literal: true

module Parkzhrun
  class ActivityCreator < ApplicationService
    def initialize(date)
      @date = date
    end

    def call
      if activity.results.exists?
        Rails.logger.warn("Parkzrun activity #{date_param} already exists")
        return false
      end

      activity.transaction do
        create_results
        create_volunteers
        activity.update!(published: true)
      end
    end

    private

    def activity
      @activity ||= Activity.find_or_create_by!(date: @date, event: Event.find_by(code_name: 'parkzhrun'))
    end

    def date_param
      @date_param ||= @date.strftime('%Y-%m-%d')
    end

    def create_results
      Client.fetch('results', date_param).each do |result|
        Result.create!(
          position: result['position'],
          total_time: Result.total_time(*result['total_time'].split(':').map(&:to_i)),
          athlete: AthleteFinder.call(result['athlete_id']),
          activity: activity,
        )
      end
    end

    def create_volunteers
      Client.fetch('volunteers', date_param).each do |result|
        volunteer = Volunteer.new(
          role: result['role_id'].to_i,
          athlete: AthleteFinder.call(result['volunteer_id']),
          activity: activity,
        )
        Rollbar.warn "Can't add volunteer to Parkzhrun activity #{activity.id}" unless volunteer.save
      end
    end
  end
end
