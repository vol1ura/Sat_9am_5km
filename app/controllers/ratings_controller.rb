# frozen_string_literal: true

class RatingsController < ApplicationController
  def results
    scope =
      Result
        .joins(activity: { event: :country })
        .where(country: { code: top_level_domain })
        .includes(athlete: :club, activity: :event)
    @male_results = scope.top(male: true, limit: 50)
    @female_results = scope.top(male: false, limit: 50)
  end

  def volunteers
    athlete_ids =
      Volunteer
        .published
        .joins(activity: { event: :country })
        .where(country: { code: top_level_domain })
        .select(:athlete_id)
        .distinct(:athlete_id)
    @volunteers =
      Volunteer.published.where(athlete_id: athlete_ids).group(:athlete).order(Arel.sql('COUNT(*) DESC')).limit(50).count
  end
end
