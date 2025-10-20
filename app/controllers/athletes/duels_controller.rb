# frozen_string_literal: true

module Athletes
  class DuelsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_athlete
    before_action :check_athlete_permissions
    before_action :ensure_athlete_has_friends

    def index
      @friend_id = params[:friend_id]
      @duels_data = Athletes::DuelsService.call(@current_athlete, friend_id: @friend_id)
      @friends = @current_athlete.friends.includes(:user, :event)
    end

    def show
      @friend = Athlete.find(params[:id])
      @duels_data = Athletes::DuelsService.call(@current_athlete, friend_id: @friend.id)
      @friend_duels = @duels_data[@friend]
    end

    private

    def set_athlete
      @athlete = Athlete.find(params[:athlete_id])
      @current_athlete = current_user.athlete
    end

    def check_athlete_permissions
      return if @current_athlete && @athlete.id == @current_athlete.id

      redirect_to root_path, alert: t('.no_access')
    end

    def ensure_athlete_has_friends
      return if @current_athlete.friends.any?

      redirect_to athlete_path(@current_athlete), notice: t('.no_friends')
    end
  end
end
