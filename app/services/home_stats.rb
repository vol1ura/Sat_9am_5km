# frozen_string_literal: true

class HomeStats < ApplicationService
  CACHE_TTL = 1.week

  def initialize(country_code)
    @country_code = country_code
  end

  def call
    Rails.cache.fetch(['pages/home_stats', @country_code], expires_in: CACHE_TTL) { compute }
  end

  private

  def compute
    {
      events: Event.in_country(@country_code).without_friends.unscope(:order).count,
      activities: published_activities.count,
      participants: published_results.distinct.count(:athlete_id),
      finishes: published_results.count,
      volunteers: published_volunteers.distinct.count(:athlete_id),
      volunteerings: published_volunteers.count,
    }
  end

  def published_activities
    @published_activities ||= Activity.published.in_country(@country_code)
  end

  def published_results = Result.where(activity_id: published_activities.select(:id))

  def published_volunteers = Volunteer.where(activity_id: published_activities.select(:id))
end
