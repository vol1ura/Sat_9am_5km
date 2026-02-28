# frozen_string_literal: true

class EmptyClubsCleanupJob < ApplicationJob
  queue_as :low

  def perform
    Club
      .where.missing(:athletes)
      .where(updated_at: ..6.months.ago)
      .where('COALESCE(LENGTH(clubs.description), 0) < 150')
      .destroy_all
  end
end
