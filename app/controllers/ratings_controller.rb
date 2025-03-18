# frozen_string_literal: true

class RatingsController < ApplicationController
  before_action :set_rating_variables, only: %i[index table]
  before_action :set_page, only: %i[table results_table]

  RATINGS = %w[count h_index uniq_events trophies].freeze
  PER_PAGE = 50
  MAX_PAGE = 20

  def index; end

  def table
    render partial: 'table', locals: { athletes: athletes_dataset }
  end

  def results; end

  def results_table
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

    scope = country_dataset_for(Result).includes(athlete: :club, activity: :event)
    scope.top(male: params[:male] == 'true').offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
  end

  def set_rating_variables
    @rating_type = params[:rating_type] == 'volunteers' ? 'volunteers' : 'results'
    @order = RATINGS.include?(params[:order]) ? params[:order] : 'count'
  end

  def set_page
    @page = (params[:page] || 1).to_i
  end
end
