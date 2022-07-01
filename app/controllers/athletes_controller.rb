# frozen_string_literal: true

class AthletesController < ApplicationController
  def index
    @athletes = Athlete.where('name ILIKE ?', "%#{params[:name]}%")
  end

  def show
    @athlete = Athlete.find(params[:id])
    @total_results = @athlete.results.size
  end
end
