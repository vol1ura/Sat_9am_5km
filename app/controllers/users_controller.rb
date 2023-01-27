# frozen_string_literal: true

class UsersController < ApplicationController
  def update
    @user = User.find(params[:id])
    redirect_to edit_user_registration_path and return unless @user.update(user_params)

    redirect_to athlete_path(@user.athlete), notice: t('views.update')
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :first_name, :last_name)
  end
end
