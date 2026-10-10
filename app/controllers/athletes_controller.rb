# frozen_string_literal: true

class AthletesController < ApplicationController
  before_action :set_athlete_profile, only: %i[show summary results volunteering friends]
  before_action :redirect_html_athlete_tab, only: %i[summary results volunteering friends]

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
    @current_tab = :summary
    load_summary_data
    @barcode = BarcodeService.call("A#{@athlete.code}", module_size: 8)
  end

  def summary
    @current_tab = :summary
    load_summary_data
    render :swap_tab
  end

  def results
    @current_tab = :results
    @results = results_with_event.load
    render :swap_tab
  end

  def volunteering
    @current_tab = :volunteering
    @volunteering = volunteering_with_event.load
    render :swap_tab
  end

  def friends
    @current_tab = :friends
    render :swap_tab
  end

  def best_result
    since_date = params.key?(:since_date) ? Date.parse(params[:since_date]) : Date.new(2022)
    @athlete = Athlete.find_by!(Athlete::PersonalCode.new(params.expect(:code).to_i).to_params)
    @result = @athlete.results.published.where(activity: { date: since_date.. }).order(:total_time).first
  rescue Date::Error => e
    render json: { error: e.message }, status: :unprocessable_content
  end

  private

  def set_athlete_profile
    @athlete = Athlete.find params.expect(:id)
    return redirect_unregistered_athlete if !@athlete.user_id && @athlete.fiveverst_code

    load_profile_nav
  end

  def redirect_unregistered_athlete
    if user_signed_in?
      redirect_to activities_path, notice: t('athletes.show.profile_hidden')
    else
      redirect_to new_user_registration_path, alert: t('athletes.show.registration_required')
    end
  end

  def load_profile_nav
    @total_results = published_results.count
    @total_vol = @athlete.volunteering.count
    @friends_count = @athlete.friendships.count
    @followers_count = @athlete.followers.count
    @has_friends_tab = @friends_count.positive? || @followers_count.positive?
  end

  def load_summary_data
    @recent_results = results_with_event.limit(10).load
    @recent_volunteering = volunteering_with_event.limit(10).load
    @total_trophies = @athlete.trophies.size
    @recent_trophies_count = recent_trophies_count
    @personal_best = published_results
      .where(personal_best: true)
      .order(:total_time, :date)
      .select(:total_time, 'date AS activity_date')
      .first
    first_event_dates = @athlete.first_event_visit_dates
    @total_events_count = first_event_dates.size
    @recent_events = first_event_dates.any? { |_event_id, date| date >= 6.days.ago.to_date }
    @time_predictions = Athletes::TimePredictor.call(@athlete)
    return if @total_results.zero?

    @top_position_counts = published_results.group(:position).order(:position).count.first(5).to_h
  end

  def recent_trophies_count
    @athlete.trophies.joins(:badge).where(
      'COALESCE(trophies.date, badges.received_date, trophies.created_at::date) >= ?',
      6.days.ago.to_date,
    ).count
  end

  def redirect_html_athlete_tab
    redirect_to athlete_path(@athlete) unless request.format.turbo_stream?
  end

  def results_with_event
    @athlete.published_results.eager_load(:activity).preload(activity: :event).order(date: :desc)
  end

  def volunteering_with_event
    @athlete.published_volunteering.eager_load(:activity).preload(activity: :event).order(date: :desc)
  end

  def published_results
    @published_results ||= @athlete.results.published
  end
end
