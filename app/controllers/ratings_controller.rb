# frozen_string_literal: true

class RatingsController < ApplicationController
  def athletes
    @athletes = ratings_for(Result)
  end

  def volunteers
    @volunteers = ratings_for(Volunteer)
  end

  def results
    scope = country_dataset_for(Result).includes(athlete: :club, activity: :event)
    @male_results = scope.top(male: true, limit: 50)
    @female_results = scope.top(male: false, limit: 50)
  end

  private

  def ratings_for(model)
    athlete_ids = country_dataset_for(model).select(:athlete_id).distinct(:athlete_id)
    @volunteers =
      model.published.where(athlete_id: athlete_ids).group(:athlete).order(Arel.sql('COUNT(*) DESC')).limit(50).count
  end

  def country_dataset_for(model)
    model.published.joins(activity: { event: :country }).where(country: { code: top_level_domain })
  end
end
