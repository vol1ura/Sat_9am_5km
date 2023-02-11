# frozen_string_literal: true

class AthletesController < ApplicationController
  def index
    query = params[:name].to_s.strip
    criteria = Athlete.includes(:club)
    @athletes =
      if query.length < 3
        Athlete.none
      elsif query.match?(/^\d+$/)
        personal_code = Athlete::PersonalCode.new(query.to_i)
        criteria.where(personal_code.code_type => personal_code.id)
      else
        criteria.where('name ILIKE :query', query: "%#{query}%")
      end
  end

  def show
    @athlete = Athlete.find(params[:id])
    results = @athlete.results.published
    @pb_by_time = results.order(:total_time).first
    @pb_by_position = results.joins(:activity).where(position: results.minimum(:position)).order(date: :desc)
    @total_results = results.size
    @total_vol = @athlete.volunteering.size
    @barcode = BarcodePrinter.call(@athlete)
  end
end
