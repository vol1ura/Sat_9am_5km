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
    @friends = @athlete.friends.includes({ user: { image_attachment: :blob } }, :event)
    @has_friends = @friends.exists?

    today = Date.current
    @target_date = today.saturday? ? today : Date.tomorrow.prev_week(:saturday)

    if @has_friends
      friend_ids = @friends.ids
      ids = friend_ids | [@athlete.id]

      @results = Result
                 .published
                 .includes({ activity: :event }, athlete: [:club, { user: { image_attachment: :blob } }])
                 .joins(:activity)
                 .where(activity: { date: @target_date }, athlete_id: ids)
                 .order('total_time ASC, position ASC')

      @my_result = @results.find { |r| r.athlete_id == @athlete.id }

      @volunteers = Volunteer
                    .published
                    .includes(:athlete)
                    .joins(:activity)
                    .where(activity: { date: @target_date }, athlete_id: friend_ids)
                    .order(:role, :athlete_id)

      @volunteers_by_role = @volunteers.group_by(&:role)
    else
      @results = []
      @volunteers_by_role = {}
    end

    @not_published_yet = today.saturday? && !Activity.published.where(date: @target_date).exists?
  end

  private

  def set_current_athlete!
    @athlete = current_user.athlete

    redirect_to new_user_session_path, alert: t('.no_athlete_access') unless @athlete
  end
end
