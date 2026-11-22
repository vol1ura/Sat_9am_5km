# frozen_string_literal: true

module Activities
  class Publish < ApplicationService
    def initialize(activity)
      @activity = activity
    end

    def call
      errors = nil
      @activity.with_lock do
        errors = PublicationReadiness.call(@activity)
        @activity.update!(published: true, token: nil) if errors.empty?
      end
      errors
    end
  end
end
