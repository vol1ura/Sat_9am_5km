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
    @athlete = Athlete.find params[:id]
    return redirect_unregistered_athlete if !@athlete.user_id && @athlete.fiveverst_code

    load_athlete_results
    load_athlete_volunteering
    @total_events_count = total_events_count
    @total_trophies = @athlete.trophies.size
    @barcode = BarcodeService.call("A#{@athlete.code}", module_size: 8)
    @time_predictions = Athletes::TimePredictor.call(@athlete)
  end

  def best_result
    since_date = params.key?(:since_date) ? Date.parse(params[:since_date]) : Date.new(2022)
    @athlete = Athlete.find_by!(Athlete::PersonalCode.new(params[:code].to_i).to_params)
    @result = @athlete.results.published.where(activity: { date: since_date.. }).order(:total_time).first
  rescue Date::Error => e
    render json: { error: e.message }, status: :unprocessable_content
  end

  private

  def redirect_unregistered_athlete
    if user_signed_in?
      redirect_to activities_path, notice: t('.profile_hidden')
    else
      redirect_to new_user_registration_path, alert: t('.registration_required')
    end
  end

  def published_results
    @published_results ||= @athlete.results.published
  end

  def load_athlete_results
    @results = published_results.includes(activity: :event).order(date: :desc).load
    @personal_best = published_results.order(:total_time, :date).select(:total_time, 'date AS activity_date').first
    @last_best_position_result =
      published_results.order(position: :asc, date: :desc).select(:position, 'date AS activity_date').first
  end

  def load_athlete_volunteering
    @volunteering = @athlete.volunteering.includes(activity: :event).load
    @total_vol = @volunteering.size
  end

  def total_events_count
    result_event_ids = published_results.distinct.pluck(:event_id)
    volunteer_event_ids = @volunteering.map { |volunteer| volunteer.activity.event_id }.uniq

    (result_event_ids + volunteer_event_ids).uniq.count
  end
end
