# frozen_string_literal: true

# Controller for managing friendships between athletes
class FriendshipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_athlete
  before_action :set_friend, only: :create
  before_action :set_friendship, only: :destroy
  before_action :set_viewed_athlete

  def create
    @athlete.friends << @friend unless @athlete.friend?(@friend)
    set_friendships_hash
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to athlete_path(@friend), notice: t('.success') }
    end
  end

  def destroy
    @friend = @friendship.friend
    @friendship.destroy
    set_friendships_hash
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to athlete_path(@friend), notice: t('.success') }
    end
  end

  private

  def set_athlete
    @athlete = current_user.athlete
  end

  def set_friend
    @friend = Athlete.find(params[:friend_id])
  end

  def set_friendship
    @friendship = @athlete.friendships.find(params[:id])
  end

  def set_viewed_athlete
    @viewed_athlete = params[:viewed_athlete_id] ? Athlete.find(params[:viewed_athlete_id]) : @friend
  end

  def set_friendships_hash
    @friendships_hash = @athlete.friendships.pluck(:friend_id, :id).to_h
  end
end
