# frozen_string_literal: true

class UsersController < ApplicationController
  PERMITTED_PARAMS = %w[first_name last_name].freeze

  before_action :authenticate_user!

  def show; end

  def edit
    @field = params[:field]
    redirect_to user_path unless PERMITTED_PARAMS.include?(@field)
  end

  def update
    @field = user_params.keys.first
    if @field && current_user.update(user_params.slice(@field))
      render partial: 'field', locals: { field: @field }
    else
      render 'edit'
    end
  end

  private

  def user_params
    @user_params ||= params.require(:user).permit(*PERMITTED_PARAMS)
  end
end
