# frozen_string_literal: true

class ResultsController < ApplicationController
  def top
    scope =
      Result
        .joins(activity: { event: :country })
        .where(country: { code: top_level_domain })
        .includes(athlete: :club, activity: :event)
    @male_results = scope.top(male: true, limit: 50)
    @female_results = scope.top(male: false, limit: 50)
  end
end
