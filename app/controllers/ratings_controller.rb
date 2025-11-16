# frozen_string_literal: true

class RatingsController < ApplicationController
  before_action :set_rating_variables, only: %i[index table]
  before_action :set_page, only: %i[table results_table]

  RATINGS = %w[count h_index uniq_events longest_streak trophies].freeze
  PER_PAGE = 50
  MAX_PAGE = 20
  RANKING_SQL =
    <<~SQL.squish
      ROW_NUMBER() OVER (
        PARTITION BY results.athlete_id
        ORDER BY results.total_time ASC, results.id DESC
      ) AS rn
    SQL
  ORDER_BY_SQL = 'ranked_results.total_time ASC, ranked_results.position ASC, ranked_results.activity_id ASC'

  def index; end

  def table
    render partial: 'table', locals: { athletes: athletes_dataset }
  end

  def results
    @club = Club.find_by(id: params[:club_id]) if params[:club_id].present?
    @event = Event.find_by(id: params[:event_id]) if params[:event_id].present?
  end

  def results_table
    @with_absolute_position = params[:name].present?
    render partial: 'results_table', locals: { results: results_dataset }
  end

  private

  def country_dataset_for(model)
    model.published.joins(activity: { event: :country }).where(country: { code: top_level_domain })
  end

  def sort_order_sql
    second_order_type =
      if @order == 'count'
        @rating_type == 'results' ? 'volunteers' : 'results'
      else
        @rating_type
      end

    "(stats #> '{#{@rating_type},#{@order}}')::integer DESC NULLS LAST," \
      "(stats #> '{#{second_order_type},count}')::integer DESC NULLS LAST," \
      'name'
  end

  def athletes_dataset
    return Athlete.none if @page > MAX_PAGE

    Athlete
      .includes(:club)
      .where(id: country_dataset_for(@rating_type.singularize.camelize.constantize).select(:athlete_id).distinct)
      .order(Arel.sql(sort_order_sql))
      .offset((@page - 1) * PER_PAGE)
      .limit(PER_PAGE)
  end

  def results_dataset
    return Result.none if @page > MAX_PAGE

    ds = Result.from(
      Result
        .from(ranked_results_dataset, :ranked_results)
        .where('ranked_results.rn = 1')
        .order(ORDER_BY_SQL)
        .select('ranked_results.*', "ROW_NUMBER() OVER (ORDER BY #{ORDER_BY_SQL}) AS ranked_position"),
      :ratings,
    )
    ds = ds.where('ratings.name ILIKE ?', "%#{params[:name].to_s.strip.first(128)}%") if params[:name].present?
    ds.select('ratings.*').preload(athlete: :club, activity: :event).offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
  end

  def ranked_results_dataset
    base_ds = country_dataset_for(Result).joins(:athlete).where(athlete: { male: params[:gender] != 'female' })
    base_ds = base_ds.where(athlete: { club_id: params[:club_id] }) if params[:club_id].present?
    base_ds = base_ds.where(activity: { event_id: params[:event_id] }) if params[:event_id].present?
    base_ds.select('results.*', 'athlete.name AS name', RANKING_SQL)
  end

  def set_rating_variables
    @rating_type = params[:type] == 'volunteers' ? 'volunteers' : 'results'
    @order = RATINGS.include?(params[:order]) ? params[:order] : 'count'
  end

  def set_page
    @page = params[:page]&.to_i || 1
  end
end
