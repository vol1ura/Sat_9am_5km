# frozen_string_literal: true

class ResultsController < ApplicationController
  def top
    scope = Result.includes(activity: :event, athlete: :club)
    @male_results = scope.top(male: true, limit: 50)
    @female_results = scope.top(male: false, limit: 50)
  end
end
