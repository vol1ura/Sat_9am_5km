# frozen_string_literal: true

module Athletes
  class Reuniter < ApplicationService
    SKIPPED_ATTRIBUTES = %w[id created_at updated_at name user_id stats].freeze
    MODIFIED_ATTRIBUTES = %w[parkrun_code fiveverst_code parkzhrun_code runpark_code club_id event_id male].freeze
    private_constant :SKIPPED_ATTRIBUTES, :MODIFIED_ATTRIBUTES

    def initialize(collection, ids)
      @collection = collection
      @ids = ids
    end

    def call
      return false if @collection.where.not(user_id: nil).size > 1
      return false unless athlete

      grab_modified_attributes_from_collection!
      replace_all_by_one!
      StatsUpdate.call(athlete)
      ClearCache.call
      true
    rescue StandardError => e
      Rollbar.error e, ids: @ids.inspect
      false
    end

    private

    def athlete
      @athlete ||= @collection.where.not(user_id: nil).take || @collection.where.not(name: nil).take
    end

    def grab_modified_attributes_from_collection!
      MODIFIED_ATTRIBUTES.each do |attr|
        athlete.public_send "#{attr}=", athlete.send(attr) || @collection.where.not(attr => nil).take&.send(attr)
        unmodified_attributes.delete(attr)
      end

      return if unmodified_attributes.empty?

      raise "Athletes reuniter skips modification of public attribute(s): #{unmodified_attributes.join(', ')}"
    end

    def unmodified_attributes
      @unmodified_attributes ||= athlete.attribute_names - SKIPPED_ATTRIBUTES
    end

    def replace_all_by_one!
      ActiveRecord::Base.transaction do
        # rubocop:disable Rails/SkipsModelValidations
        Result.where(athlete_id: @ids).update_all(athlete_id: athlete.id)
        Volunteer.where(athlete_id: @ids).update_all(athlete_id: athlete.id)
        update_all_trophies!
        @collection.where.not(id: athlete.id).destroy_all
        athlete.save!
        # rubocop:enable Rails/SkipsModelValidations
      end
    end

    def update_all_trophies!
      Trophy.where(athlete_id: @ids).find_each do |trophy|
        if (athlete_trophy = athlete.trophies.find_by(badge_id: trophy.badge_id))
          athlete_trophy.update!(date: trophy.date) if trophy.date && trophy.date > athlete_trophy.date
        else
          trophy.update!(athlete:)
        end
      end
    end
  end
end
