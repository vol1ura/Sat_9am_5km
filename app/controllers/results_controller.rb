# frozen_string_literal: true

class ResultsController < ApplicationController
  def top
    @male_results = Result.includes(activity: :event, athlete: :club).top(male: true, limit: 50)
    @female_results = Result.includes(activity: :event, athlete: :club).top(male: false, limit: 50)
  end
end
