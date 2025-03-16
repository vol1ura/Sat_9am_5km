# frozen_string_literal: true

class RatingsController < ApplicationController
  before_action :set_rating_variables, only: %i[index table]

  RATINGS = %w[count h_index uniq_events trophies].freeze
  PER_PAGE = 50

  def index; end

  def table
    @page = (params[:page] || 1).to_i
    @athletes = athletes_dataset

    render partial: 'table'
  end

  def results
    scope = country_dataset_for(Result).includes(athlete: :club, activity: :event)
    @male_results = scope.top(male: true, limit: 50)
    @female_results = scope.top(male: false, limit: 50)
  end

  private

  def country_dataset_for(model)
    model.published.joins(activity: { event: :country }).where(country: { code: top_level_domain })
  end

  def athletes_dataset
    second_order_type =
      if @order == 'count'
        @rating_type == 'results' ? 'volunteers' : 'results'
      else
        @rating_type
      end
    sort_order_sql =
      "(stats #> '{#{@rating_type},#{@order}}')::integer DESC NULLS LAST," \
      "(stats #> '{#{second_order_type},count}')::integer DESC NULLS LAST," \
      'name'
    Athlete
      .includes(:club)
      .where(id: country_dataset_for(@rating_type.singularize.camelize.constantize).select(:athlete_id).distinct)
      .order(Arel.sql(sort_order_sql))
      .offset((@page - 1) * PER_PAGE)
      .limit(PER_PAGE)
  end

  def set_rating_variables
    @rating_type = params[:rating_type] == 'volunteers' ? 'volunteers' : 'results'
    @order = RATINGS.include?(params[:order]) ? params[:order] : 'count'
  end
end
