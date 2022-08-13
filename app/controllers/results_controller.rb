# frozen_string_literal: true

class ResultsController < ApplicationController
  def top
    @male_results = Result.top(male: true, limit: 50)
    @female_results = Result.top(male: false, limit: 50)
  end
end
