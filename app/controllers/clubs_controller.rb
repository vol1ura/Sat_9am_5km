# frozen_string_literal: true

class ClubsController < ApplicationController
  def index
    @q = Club
      .joins(:country)
      .where(country: { code: top_level_domain })
      .ransack(params[:q])
    @q.sorts = 'athletes_count desc' if @q.sorts.empty?
    @clubs = @q.result.page(params[:page]).per(25)
    @count_athletes =
      Athlete
        .joins(club: :country)
        .where(country: { code: top_level_domain })
        .group(:club_id)
        .count(:club_id)
    @count_results = group_and_count_clubs_for Result
    @count_volunteering = group_and_count_clubs_for Volunteer
  end

  def search
    @clubs =
      Club
        .joins(:country)
        .where(country: { code: top_level_domain })
        .where('name ILIKE ?', "%#{params[:q]}%")
        .order(:name)
        .page(params[:page])
        .per(20)
    render turbo_stream: helpers.async_combobox_options(@clubs, next_page: @clubs.last_page? ? nil : @clubs.next_page)
  end

  def show
    @club = Club.find(params[:id])
    @count_results =
      Athlete
        .left_joins(results: :activity)
        .where(club: @club, activity: { published: true })
        .group('athletes.id')
        .count('results.id')
    @count_volunteering = Athlete.left_joins(:volunteering).where(club: @club).group('athletes.id').count('volunteers.id')
    @athletes = Athlete.where(club: @club).order(:name)
    @total_results_count = Result.published.joins(:athlete).where(athlete: { club: @club }).size
    @total_volunteering_count = Volunteer.published.joins(:athlete).where(athlete: { club: @club }).size
  end

  def last_week
    @club = Club.find(params[:id])
    today = Date.current
    date_interval = (today.cwday < 6 ? today.prev_week : today).all_week
    activities_dataset =
      Activity.published.joins(:event).where(date: date_interval, athletes: { club: @club }).includes(:event).distinct
    @activities_with_results = activities_dataset.joins(results: :athlete)
    @activities_with_volunteers = activities_dataset.joins(volunteers: :athlete)
  end

  private

  def group_and_count_clubs_for(entity)
    entity
      .published
      .joins(athlete: { club: :country })
      .where(country: { code: top_level_domain })
      .group(:club_id)
      .count(:club_id)
  end
end
