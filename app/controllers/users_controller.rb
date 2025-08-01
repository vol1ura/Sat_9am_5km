# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :reset_attributes, only: :update

  def show; end

  def edit; end

  def update
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

  def reset_attributes
    if params[:delete_phone]
      current_user.phone = nil
      current_user.promotions = []
    elsif params.dig(:user, :promotions).blank?
      current_user.promotions = []
    end
  end

  def user_params
    params.expect(
      user: [
        :first_name,
        :last_name,
        :image,
        :emergency_contact_name,
        :emergency_contact_phone,
        { promotions: [] },
        {
          athlete_attributes:
            %i[id event_id club_id personal_record_10k personal_record_half_marathon personal_record_marathon],
        },
      ],
    )
  end
end
