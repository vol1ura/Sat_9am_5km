# frozen_string_literal: true

module Users
  class DestroyRegistration < ApplicationService
    def initialize(user)
      @user = user
    end

    def call
      athlete = @user.athlete

      @user.destroy!

      return unless athlete
      return if athlete.results.exists? || Volunteer.exists?(athlete:)

      athlete.destroy!
    end
  end
end
