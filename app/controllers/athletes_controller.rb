# frozen_string_literal: true

class AthletesController < ApplicationController
  def index
    @athletes =
      if params[:name].blank?
        Athlete.none
      elsif params[:name].match?(/\A\d+\z/)
        Athlete.where('parkrun_code = :number OR fiveverst_code = :number', number: params[:name].to_i)
      else
        Athlete.where('name ILIKE :query', query: "%#{params[:name]}%")
      end
  end

  def show
    @athlete = Athlete.find(params[:id])
    @total_results = @athlete.results.published.size
    @total_vol = @athlete.volunteering.size
  end
end
