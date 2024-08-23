# frozen_string_literal: true

class AthletesController < ApplicationController
  def index
    query = params[:name].to_s.gsub(/[^[:alnum:][:blank:]]/, '').strip
    criteria = Athlete.order(:event_id).limit(100)
    @athletes =
      if query.length < 3
        Athlete.none
      elsif query.match?(/^\d+$/)
        personal_code = Athlete::PersonalCode.new(query.to_i)
        criteria.where(personal_code.code_type => personal_code.id)
      else
        criteria.search_by_name(query)
      end
    redirect_to athlete_path(@athletes.take) if request.format.html? && @athletes.length == 1
  end

  def show
    @athlete = Athlete.find(params[:id])
    results = @athlete.results.published
    @total_results = results.size
    if @total_results.positive?
      @pb_by_time = results.where(personal_best: true).order(date: :desc)
      @best_position = results.minimum(:position)
      @pb_by_position = results.includes(activity: :event).where(position: @best_position).order(date: :desc)
      @total_events = results.select(:event_id).distinct.count
    end
    @volunteering = @athlete.volunteering
    @total_vol = @volunteering.size
    @total_trophies = @athlete.trophies.size
    @barcode = BarcodePrinter.call(@athlete)
  end
end
