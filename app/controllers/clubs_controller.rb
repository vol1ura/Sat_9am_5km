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
    now = Time.current
    date_interval = (now.wday < 6 ? now.prev_week : now).all_week
    @events_with_athletes =
      Event
        .joins(activities: { results: :athlete })
        .where(activities: { published: true, date: date_interval }, athletes: { club: @club })
        .distinct
    @events_with_volunteers =
      Event
        .joins(activities: { volunteers: :athlete })
        .where(activities: { published: true, date: date_interval }, athletes: { club: @club })
        .distinct
    @last_week_results = Result.published.joins(:athlete).where(athlete: { club: @club }, activity: { date: date_interval })
    @last_week_volunteerings =
      Volunteer.published.joins(:athlete).where(athlete: { club: @club }, activity: { date: date_interval })
  end
end
