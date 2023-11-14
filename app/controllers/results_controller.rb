# frozen_string_literal: true

class ResultsController < ApplicationController
  def top
    scope =
      Result
        .includes(athlete: :club, activity: :event)
        .where(activity: { events: { country_code: top_level_domain } })
    @male_results = scope.top(male: true, limit: 50)
    @female_results = scope.top(male: false, limit: 50)
  end
end
