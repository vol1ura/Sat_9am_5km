# frozen_string_literal: true

module Athletes
  class Reuniter < ApplicationService
    SKIPPED_ATTRIBUTES = %w[id created_at updated_at name user_id stats].freeze
    MODIFIED_ATTRIBUTES = %w[
      parkrun_code fiveverst_code parkzhrun_code runpark_code club_id event_id going_to_event_id male
    ].freeze
    private_constant :SKIPPED_ATTRIBUTES, :MODIFIED_ATTRIBUTES

    def initialize(collection, ids)
      @collection = collection
      @ids = ids
    end

    def call
      return false if @collection.where.not(user_id: nil).many?
      return false unless athlete

      grab_modified_attributes_from_collection!
      update_results_seconds
      replace_all_by_one!
      AthleteStatsUpdateJob.perform_later(athlete.id)
      schedule_telegram_notification
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
        athlete.public_send(:"#{attr}=", @collection.where.not(attr => nil).take&.send(attr)) unless athlete.send(attr)
        unmodified_attributes.delete(attr)
      end

      return if unmodified_attributes.empty?

      raise "Athletes reuniter skips modification of public attribute(s): #{unmodified_attributes.join(', ')}"
    end

    def unmodified_attributes
      @unmodified_attributes ||= athlete.attribute_names - SKIPPED_ATTRIBUTES
    end

    def update_results_seconds
      athlete_seconds = @collection.pluck(:stats).sum([]) { |s| s.dig('results', 'seconds') || [] }.uniq.sort
      athlete.stats.deep_merge!('results' => { 'seconds' => athlete_seconds })
    end

    def replace_all_by_one!
      ActiveRecord::Base.transaction do
        Result.where(athlete_id: @ids).update_all(athlete_id: athlete.id)
        Volunteer.where(athlete_id: @ids).update_all(athlete_id: athlete.id)
        update_all_trophies!
        @collection.excluding(athlete).destroy_all
        athlete.save!
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

    def schedule_telegram_notification
      return unless athlete.user_id

      inform_date = Date.current.noon.future? ? Date.current.noon : Date.tomorrow + 10.hours
      Telegram::Notification::AfterReuniteJob.set(wait_until: inform_date).perform_later(athlete.user_id)
    end
  end
end
