# frozen_string_literal: true

class RatingsController < ApplicationController
  RATINGS = %w[count h_index uniq_events trophies].freeze

  def index
    @rating_type = params[:rating_type] == 'volunteers' ? 'volunteers' : 'results'
    @order = RATINGS.include?(params[:order]) ? params[:order] : 'count'
    @athletes = athletes_dataset

    respond_to do |format|
      format.html
      format.turbo_stream { render turbo_stream: turbo_stream.replace('ratings_table', partial: 'ratings_table') }
    end
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
    athlete_ids = country_dataset_for(@rating_type.singularize.camelize.constantize).select(:athlete_id).distinct
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

    Athlete.includes(:club).where(id: athlete_ids).order(Arel.sql(sort_order_sql)).limit(50)
  end
end
