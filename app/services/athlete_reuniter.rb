# frozen_string_literal: true

class AthleteReuniter < ApplicationService
  def initialize(collection, ids)
    @collection = collection
    @ids = ids
  end

  def call
    return false unless athlete

    grab_fields_from_collection
    replace_all_by_one and return true
  rescue StandardError => e
    Rails.logger.error e.inspect
    false
  end

  private

  attr_reader :collection, :ids

  def athlete
    @athlete ||= collection.where.not(name: nil).take
  end

  def grab_fields_from_collection
    athlete.parkrun_code ||= collection.where.not(parkrun_code: nil).take&.parkrun_code
    athlete.fiveverst_code ||= collection.where.not(fiveverst_code: nil).take&.fiveverst_code
    athlete.user_id ||= collection.where.not(user_id: nil).take&.user_id
    athlete.male ||= collection.where.not(male: nil).take&.male
  end

  def replace_all_by_one
    ActiveRecord::Base.transaction do
      Result.where(athlete_id: ids).update_all(athlete_id: athlete.id) # rubocop:disable Rails/SkipsModelValidations
      Volunteer.where(athlete_id: ids).update_all(athlete_id: athlete.id) # rubocop:disable Rails/SkipsModelValidations
      collection.where.not(id: athlete.id).destroy_all
      athlete.save!
    end
  end
end
