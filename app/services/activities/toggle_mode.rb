# frozen_string_literal: true

module Activities
  class ToggleMode < ApplicationService
    def initialize(activity, automatic:)
      @activity = activity
      @automatic = automatic
    end

    def call
      return @activity if @automatic == @activity.token?

      @activity.with_lock do
        raise ActiveRecord::RecordInvalid, @activity unless @activity.mode_switchable?

        @activity.update!(token: @automatic ? SecureRandom.uuid : nil)
        @activity.clear_live_results!
      end
      @activity
    end
  end
end
