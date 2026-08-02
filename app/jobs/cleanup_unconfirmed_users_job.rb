# frozen_string_literal: true

class CleanupUnconfirmedUsersJob < ApplicationJob
  queue_as :low

  def perform
    User.where(confirmed_at: nil).where(created_at: ..3.hours.ago).preload(:athlete, :permissions).find_each do |user|
      Users::DestroyRegistration.call user
    end
  end
end
