# frozen_string_literal: true

module Athletes
  class Reuniter < ApplicationService
    SKIPPED_ATTRIBUTES = %w[id created_at updated_at name user_id stats personal_bests].freeze
    ATHLETE_MODIFIED_ATTRIBUTES = %w[
      parkrun_code fiveverst_code parkzhrun_code runpark_code club_id event_id going_to_event_id gender
    ].freeze
    USER_MODIFIED_ATTRIBUTES = %w[phone emergency_contact_name emergency_contact_phone].freeze
    private_constant :SKIPPED_ATTRIBUTES, :ATHLETE_MODIFIED_ATTRIBUTES, :USER_MODIFIED_ATTRIBUTES

    def initialize(collection, ids)
      @collection = collection
      @ids = ids
    end

    def call
      return false unless athlete

      merge_users!
      grab_modified_attributes_from_collection!
      update_results_seconds
      replace_all_by_one!
      AthleteStatsUpdateJob.perform_later athlete.id
      AthletePersonalBestsUpdateJob.perform_later athlete.id
      schedule_telegram_notification
      true
    rescue StandardError => e
      Rollbar.error e, ids: @ids.inspect
      false
    end

    private

    def athlete
      @athlete ||= email_user&.athlete || telegram_user&.athlete || @collection.where.not(name: nil).take
    end

    def athletes_with_users
      @athletes_with_users ||= @collection.where.not(user_id: nil).includes(:user).to_a
    end

    def mergeable_users?
      return false unless email_user && telegram_user && email_user != telegram_user
      return false if email_user.telegram_id && email_user.telegram_id != telegram_user.telegram_id

      true
    end

    def email_user
      @email_user ||= athletes_with_users.map(&:user).find(&:email)
    end

    def telegram_user
      @telegram_user ||= athletes_with_users.map(&:user).find do |user|
        user.telegram_id && user != email_user
      end
    end

    def merge_users!
      users = athletes_with_users.map(&:user).uniq
      return unless users.many?
      raise 'Only two users (email and telegram) can be merged' unless users.size == 2 && mergeable_users?

      ActiveRecord::Base.transaction do
        telegram_attributes = telegram_user.as_json(only: %w[telegram_id telegram_user])
        telegram_user.update!(telegram_id: rand(1000), telegram_user: nil) # random telegram_id to avoid validation error
        email_user.update!(mergeable_user_attributes.merge(telegram_attributes))
        email_user.image.attach(telegram_user.image.blob) if !email_user.image.attached? && telegram_user.image.attached?
        telegram_user.destroy!
      end
    end

    def mergeable_user_attributes
      USER_MODIFIED_ATTRIBUTES.index_with do |attr|
        telegram_user.public_send(attr).presence if email_user.public_send(attr).blank?
      end.compact
    end

    def grab_modified_attributes_from_collection!
      ATHLETE_MODIFIED_ATTRIBUTES.each do |attr|
        athlete.public_send(:"#{attr}=", @collection.where.not(attr => nil).take&.send(attr)) unless athlete.send(attr)
        unmodified_attributes.delete attr
      end

      return if unmodified_attributes.empty?

      raise "Athletes reuniter skips modification of public attribute(s): #{unmodified_attributes.join(', ')}"
    end

    def unmodified_attributes
      @unmodified_attributes ||= athlete.attribute_names - SKIPPED_ATTRIBUTES
    end

    def update_results_seconds
      athlete_seconds = @collection.pluck(:stats).sum([]) { |s| s.dig('results', 'seconds') || [] }.uniq.sort
      athlete.stats.deep_merge! 'results' => { 'seconds' => athlete_seconds }
    end

    def replace_all_by_one!
      activity_ids =
        (Result.where(athlete_id: @ids).pluck(:activity_id) + Volunteer.where(athlete_id: @ids).pluck(:activity_id)).uniq
      now = Time.current
      ActiveRecord::Base.transaction do
        Result.where(athlete_id: @ids).update_all(athlete_id: athlete.id, updated_at: now)
        Volunteer.where(athlete_id: @ids).update_all(athlete_id: athlete.id, updated_at: now)
        Activity.where(id: activity_ids).touch_all
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
          trophy.update! athlete:
        end
      end
    end

    def schedule_telegram_notification
      return unless athlete.user_id

      inform_date = Date.current.noon.future? ? Date.current.noon : Date.tomorrow + 10.hours
      Notification::AfterReuniteJob.set(wait_until: inform_date).perform_later athlete.user_id
    end
  end
end
