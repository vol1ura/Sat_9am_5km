# frozen_string_literal: true

class AthletesController < ApplicationController
  def index
    query = params[:q].to_s.gsub(/[^[:alnum:][:blank:]\-']/, '').strip
    criteria = Athlete.order(:event_id).limit(100)
    @athletes =
      if query.length < 3
        Athlete.none
      elsif query.match?(/^\d+$/)
        criteria.where(**Athlete::PersonalCode.new(query.to_i).to_params)
      else
        criteria.search_by_name(query)
      end
    redirect_to athlete_path(@athletes.take) if request.format.html? && @athletes.load.one?
  end

  def show
    @athlete = Athlete.find(params[:id])
    results_ds = @athlete.results.published
    @total_results = results_ds.size
    @volunteering = @athlete.volunteering
    @total_vol = @volunteering.size
    @total_events_count =
      (results_ds.distinct.pluck(:event_id) + @volunteering.unscope(:order).distinct.pluck(:event_id)).uniq.count
    @total_trophies = @athlete.trophies.size
    @barcode = BarcodePrinter.call("A#{@athlete.code}", module_size: 8)
    @time_predictions = Athletes::TimePredictor.call(@athlete)
  end
end
