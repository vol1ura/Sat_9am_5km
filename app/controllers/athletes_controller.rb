# frozen_string_literal: true

class AthletesController < ApplicationController
  def index
    query = params[:name].to_s.strip
    criteria = Athlete.includes(:club)
    @athletes =
      if query.blank?
        Athlete.none
      elsif query.match?(/^\d+$/)
        criteria.where('parkrun_code = :number OR fiveverst_code = :number', number: query.to_i)
      else
        criteria.where('name ILIKE :query', query: "%#{query}%")
      end
  end

  def show
    @athlete = Athlete.find(params[:id])
    @total_results = @athlete.results.published.size
    @total_vol = @athlete.volunteering.size
    @barcode = BarcodePrinter.call(@athlete)
  end
end
