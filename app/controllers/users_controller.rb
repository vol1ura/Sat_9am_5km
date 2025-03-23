# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!

  def show; end

  def edit; end

  def update
    current_user.phone = nil if params[:delete_phone]

    if current_user.update(user_params)
      if params[:delete_image]
        current_user.image.purge
      elsif params[:user][:image] && current_user.image.attached?
        CompressUserImageJob.set(wait: 1.minute).perform_later current_user.id
      end

      redirect_to user_path
    else
      render :edit
    end
  end

  private

  def user_params
    params.expect(user: [:first_name, :last_name, :image, { athlete_attributes: %i[id event_id club_id] }])
  end
end
