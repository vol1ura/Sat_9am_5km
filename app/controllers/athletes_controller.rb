# frozen_string_literal: true

class AthletesController < ApplicationController
  def index
    query = params[:name].to_s.strip
    criteria = Athlete.includes(:club).order(:event_id)
    @athletes =
      if query.length < 3
        Athlete.none
      elsif query.match?(/^\d+$/)
        personal_code = Athlete::PersonalCode.new(query.to_i)
        criteria.where(personal_code.code_type => personal_code.id)
      else
        criteria.where('name ILIKE :query', query: "%#{Athlete.sanitize_sql_like(query)}%")
      end
    redirect_to athlete_path(@athletes.take) if request.format.html? && @athletes.size == 1
  end

  def show
    @athlete = Athlete.find(params[:id])
    results = @athlete.results.published
    @pb_by_time = results.order(:total_time).first
    @pb_by_position = results.joins(:activity).where(position: results.minimum(:position)).order(date: :desc)
    @total_results = results.size
    @volunteering = @athlete.volunteering
    @total_vol = @volunteering.size
    @barcode = BarcodePrinter.call(@athlete)
  end
end
