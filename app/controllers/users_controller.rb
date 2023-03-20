# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :allow_without_password, only: :update

  def update
    redirect_to edit_user_registration_path and return unless current_user.update(user_params)

    redirect_to athlete_path(current_user.athlete), notice: t('views.update')
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, athlete_attributes: %i[club_id])
  end

  def allow_without_password
    return unless params[:user][:password].blank? && params[:user][:password_confirmation].blank?

    params[:user].delete(:password)
    params[:user].delete(:password_confirmation)
  end
end
