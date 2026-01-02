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
    @last_best_position_result =
      results_ds.order(position: :asc, date: :desc).select(:position, 'date AS activity_date').first
    @volunteering = @athlete.volunteering
    @total_vol = @volunteering.size
    @total_events_count =
      (results_ds.distinct.pluck(:event_id) + @volunteering.unscope(:order).distinct.pluck(:event_id)).uniq.count
    @total_trophies = @athlete.trophies.size
    @barcode = BarcodePrinter.call("A#{@athlete.code}", module_size: 8)
    @time_predictions = Athletes::TimePredictor.call(@athlete)
  end

  def best_result
    since_date = params.key?(:since_date) ? Date.parse(params[:since_date]) : Date.new(2022)
    @athlete = Athlete.find_by!(Athlete::PersonalCode.new(params[:code].to_i).to_params)
    @result = @athlete.results.published.where(activity: { date: since_date.. }).order(:total_time).first
  rescue Date::Error => e
    render json: { error: e.message }, status: :unprocessable_content
  end
end
