# frozen_string_literal: true

class DuelsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_athlete!
  before_action :ensure_athlete_has_friends, only: :index

  def index
    @duels_data = Athletes::DuelsService.call @current_athlete
    @friends = @current_athlete.friends.includes(:user, :event)
    @athlete = @current_athlete
  end

  def show
    @friend = Athlete.find params[:id]
    @duels_data = Athletes::DuelsService.call @current_athlete, friend_id: @friend.id
    @friend_duels = @duels_data[@friend]
    @athlete = @current_athlete
  end

  private

  def set_current_athlete!
    @current_athlete = current_user.athlete
    redirect_to new_user_session_path, alert: t('.no_athlete_access') unless @current_athlete
  end

  def ensure_athlete_has_friends
    return if @current_athlete&.friends&.any?

    redirect_to athlete_path(@current_athlete), notice: t('.no_friends')
  end
end
