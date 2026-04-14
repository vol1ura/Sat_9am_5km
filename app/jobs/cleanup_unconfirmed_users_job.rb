# frozen_string_literal: true

class CleanupUnconfirmedUsersJob < ApplicationJob
  queue_as :low

  def perform
    User.where(confirmed_at: nil).where(created_at: ..1.hour.ago).preload(:athlete, :permissions).find_each do |user|
      athlete = user.athlete
      user.destroy!
      athlete.destroy if athlete && !athlete.results.exists? && !Volunteer.exists?(athlete:)
    end
  end
end
