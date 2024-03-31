# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!

  def show; end

  def edit; end

  def update
    if current_user.update(user_params)
      if params[:delete_image]
        current_user.image.purge
      else
        CompressUserImageJob.perform_later current_user.id
      end

      redirect_to user_path
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :image)
  end
end
