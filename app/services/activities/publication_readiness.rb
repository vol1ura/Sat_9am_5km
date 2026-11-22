# frozen_string_literal: true

module Activities
  class PublicationReadiness < ApplicationService
    def initialize(activity)
      @activity = activity
    end

    def call
      errors = []
      errors << 'already_published' if @activity.published?
      errors << 'automatic_mode_enabled' if @activity.token?
      errors << 'empty_protocol' if @activity.results.empty?
      errors << 'doubled_results' if @activity.doubled_results.exists?
      errors << 'incorrect_protocol' unless @activity.correct?
      errors << 'conflicting_volunteer_roles' if conflicting_volunteers?
      errors
    end

    private

    def conflicting_volunteers?
      Volunteer.incorrect_on_running_positions.exists?(activity: @activity) ||
        Volunteer.incorrect_on_non_running_positions.exists?(activity: @activity)
    end
  end
end
