# frozen_string_literal: true

class ClubsController < ApplicationController
  def index
    @clubs = Athlete.joins(:club).group(:club).order('count_clubs DESC').count(:clubs)
  end

  def show
    @club = Club.find(params[:id])
    @athletes = Result.joins(:athlete).where(athlete: { club: @club })
                      .group(:athlete).order('count_athlete DESC').count(:athlete)
  end
end
