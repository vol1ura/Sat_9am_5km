# frozen_string_literal: true

class ClubsController < ApplicationController
  def index
    @q = Club
      .joins(:country)
      .where(country: { code: top_level_domain })
      .ransack(params[:q])
    @q.sorts = 'athletes_count desc' if @q.sorts.empty?
    @clubs = @q.result.page(params[:page]).per(25)
    club_ids = @clubs.map(&:id)

    if club_ids.empty?
      @count_athletes = {}
      @results_stats = {}
      @count_volunteering = {}
      return
    end

    @count_athletes = count_athletes_for(club_ids:)
    @results_stats = count_results_for(club_ids:)
    @count_volunteering = group_and_count_clubs_for(Volunteer, club_ids:).count(:club_id)
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
    @club = Club.find_by!(slug: params[:slug].downcase)
    @count_volunteering = Athlete.left_joins(:volunteering).where(club: @club).group('athletes.id').count('volunteers.id')
    @total_results_count = Result.published.joins(:athlete).where(athlete: { club: @club }).size
    @total_volunteering_count = Volunteer.published.joins(:athlete).where(athlete: { club: @club }).size
    @athletes =
      Athlete
        .where(club: @club)
        .left_outer_joins(:published_results)
        .select('athletes.*', 'MIN(results.total_time) AS personal_best', 'COUNT(results.id) AS results_count')
        .group('athletes.id')
        .order(:name)
  end

  def last_week
    @club = Club.find_by!(slug: params[:slug].downcase)
    today = Date.current
    date_interval = (today.cwday < 6 ? today.prev_week : today).all_week
    activities_dataset =
      Activity.published.where(date: date_interval, athletes: { club: @club }).includes(:event).distinct
    @activities_with_results = activities_dataset.joins(results: :athlete)
    @activities_with_volunteers = activities_dataset.joins(volunteers: :athlete)
  end

  private

  def group_and_count_clubs_for(entity, club_ids:)
    entity
      .published
      .joins(athlete: { club: :country })
      .where(country: { code: top_level_domain })
      .where(athletes: { club_id: club_ids })
      .group(:club_id)
  end

  def count_athletes_for(club_ids:)
    Athlete
      .joins(club: :country)
      .where(country: { code: top_level_domain })
      .where(club_id: club_ids)
      .group(:club_id)
      .count(:club_id)
  end

  def count_results_for(club_ids:)
    group_and_count_clubs_for(Result, club_ids:)
      .pluck(:club_id, 'AVG(results.total_time)', 'MIN(results.total_time)', 'COUNT(results.id)')
      .to_h do |club_id, avg_seconds, best_seconds, results_count|
        [
          club_id,
          {
            avg_seconds: avg_seconds.to_f.round,
            best_seconds: best_seconds.to_i,
            count: results_count.to_i,
          },
        ]
      end
  end
end
