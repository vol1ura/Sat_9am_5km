# frozen_string_literal: true

class DuelsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_athlete!

  def index
    @duels_data = Athletes::DuelsService.call @athlete
    @friends = @athlete.friends.includes(:user, :event)
  end

  def show
    @friend = Athlete.find params[:id]
    duels_data = Athletes::DuelsService.call @athlete, friend_id: @friend.id
    @friend_duels = duels_data[@friend]
  end

  private

  def set_current_athlete!
    @athlete = current_user.athlete

    redirect_to new_user_session_path, alert: t('.no_athlete_access') unless @athlete
  end
end
