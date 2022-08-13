# frozen_string_literal: true

class ResultsController < ApplicationController
  def top
    published_results = Result.includes({ athlete: :club }, { activity: :event }).published
    @male_results = published_results.top(true, 50)
    @female_results = published_results.top(false, 50)
  end
end
