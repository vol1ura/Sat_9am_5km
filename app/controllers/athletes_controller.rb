# frozen_string_literal: true

class AthletesController < ApplicationController
  def index
    @athletes = Athlete.where(
      'name ILIKE :query OR parkrun_code = :number OR fiveverst_code = :number',
      query: "%#{params[:name]}%", number: params[:name].to_i
    )
  end

  def show
    @athlete = Athlete.find(params[:id])
    @total_results = @athlete.results.size
    @total_vol = @athlete.volunteering.size
  end
end
