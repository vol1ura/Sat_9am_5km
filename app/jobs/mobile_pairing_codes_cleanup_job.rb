# frozen_string_literal: true

class MobilePairingCodesCleanupJob < ApplicationJob
  queue_as :low

  def perform
    MobilePairingCode.where(expires_at: ..1.day.ago).delete_all
  end
end
