# frozen_string_literal: true

class DuelsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_athlete!

  def index
    @duels_data = Athletes::DuelsService.call @athlete
    @friends = @athlete.friends.includes({ user: { image_attachment: :blob } }, :event)
  end

  def show
    @friend = Athlete.find params[:id]
    duels_data = Athletes::DuelsService.call @athlete, friend_id: @friend.id
    @friend_duels = duels_data[@friend]
  end

  def protocol
    friend_ids = @athlete.friends.ids | [@athlete.id]
    @has_friends = friend_ids.many?

    today = Date.current
    @target_date = today.saturday? ? today : Date.tomorrow.prev_week(:saturday)

    @results = Result
      .published
      .includes({ activity: :event }, athlete: [:club, { user: { image_attachment: :blob } }])
      .where(activity: { date: @target_date }, athlete_id: friend_ids)
      .order(:total_time, :position)

    @volunteers = Volunteer
      .published
      .includes(:athlete)
      .where(activity: { date: @target_date }, athlete_id: friend_ids)
      .order(:role, :athlete_id)

    @volunteers_by_role = @volunteers.group_by(&:role)
  end

  private

  def set_current_athlete!
    @athlete = current_user.athlete

    redirect_to new_user_session_path, alert: t('.no_athlete_access') unless @athlete
  end
end
