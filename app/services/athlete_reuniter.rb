# frozen_string_literal: true

class AthleteReuniter < ApplicationService
  SKIPPED_ATTRIBUTES = %w[id created_at updated_at name].freeze
  MODIFIED_ATTRIBUTES = %w[parkrun_code fiveverst_code parkzhrun_code user_id club_id event_id male].freeze
  private_constant :SKIPPED_ATTRIBUTES, :MODIFIED_ATTRIBUTES

  def initialize(collection, ids)
    @collection = collection
    @ids = ids
  end

  def call
    return false unless athlete

    grab_modified_attributes_from_collection
    check_modified_fields
    replace_all_by_one
    true
  rescue StandardError => e
    Rollbar.error e
    false
  end

  private

  def athlete
    @athlete ||= @collection.where.not(name: nil).take
  end

  def grab_modified_attributes_from_collection
    MODIFIED_ATTRIBUTES.each do |attr|
      athlete.public_send "#{attr}=", athlete.send(attr) || @collection.where.not(attr => nil).take&.send(attr)
      unmodified_attributes.delete(attr)
    end
  end

  def unmodified_attributes
    @unmodified_attributes ||= athlete.attribute_names - SKIPPED_ATTRIBUTES
  end

  def check_modified_fields
    return if unmodified_attributes.empty?

    message = "AthleteReuniter skips modification of public attribute(s): #{unmodified_attributes}"
    raise message if Rails.env.test?

    Rollbar.warn message
  end

  def replace_all_by_one
    ActiveRecord::Base.transaction do
      # rubocop:disable Rails/SkipsModelValidations
      Result.where(athlete_id: @ids).update_all(athlete_id: athlete.id)
      Volunteer.where(athlete_id: @ids).update_all(athlete_id: athlete.id)
      update_all_trophies
      @collection.where.not(id: athlete.id).destroy_all
      athlete.save!
      # rubocop:enable Rails/SkipsModelValidations
    end
  end

  def update_all_trophies
    Trophy.where(athlete_id: @ids).each do |trophy|
      if (athlete_trophy = athlete.trophies.find_by(badge_id: trophy.badge_id))
        athlete_trophy.update!(date: trophy.date) if trophy.date && trophy.date > athlete_trophy.date
      else
        trophy.update!(athlete: athlete)
      end
    end
  end
end
