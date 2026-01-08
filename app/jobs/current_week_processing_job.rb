# frozen_string_literal: true

class CurrentWeekProcessingJob < ApplicationJob
  queue_as :low

  def perform
    Activity.published.where(date: Date.current.all_week).find_each do |activity|
      process_activity activity
    end

    fill_informed_flag
    ActiveStorage::Blob.unattached.find_each &:purge_later
  end

  private

  def process_activity(activity)
    ResultsProcessingJob.perform_now activity.id
    AthletesAwardingJob.perform_now activity.id
    FivePlusAwardingJob.perform_now activity.id, with_expiration: true
  end

  def fill_informed_flag
    [Result, Volunteer].each do |model|
      model
        .published
        .where(activity: { date: ...Date.current.prev_week(:saturday) }, informed: false)
        .update_all(informed: true)
    end
  end
end
