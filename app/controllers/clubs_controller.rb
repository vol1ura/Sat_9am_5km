# frozen_string_literal: true

class ClubsController < ApplicationController
  def index
    @clubs = Athlete.joins(:club).group(:club).order(count_clubs: :desc).count(:clubs)
    @count_results = Result.joins(:athlete).group(:club_id).count(:club_id)
    @count_volunteering = Volunteer.joins(:athlete).group(:club_id).count(:club_id)
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
    @total_results_count = Result.joins(:athlete).where(athlete: { club: @club }).size
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
end
