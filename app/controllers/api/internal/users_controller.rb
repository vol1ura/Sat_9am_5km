# frozen_string_literal: true

module API
  module Internal
    class UsersController < ApplicationController
      def create
        @user = User.new(user_params)
        @user.transaction do
          @user.skip_confirmation!
          @user.confirm
          @user.save!
          link_user_to_athlete!
        end

        head :created
      end

      def update
        @user = User.find(params[:user_id])
        @user.transaction do
          @user.update!(user_params)
          link_user_to_athlete!
        end

        head :ok
      end

      rescue_from ActiveRecord::RecordInvalid do |e|
        Rollbar.error e
        errors = {}
        errors[:user] = @user.errors.full_messages if @user.invalid?
        errors[:athlete] = @athlete.errors.full_messages if @athlete&.invalid?

        render json: { errors: }, status: :unprocessable_entity
      end

      private

      def user_params
        params.expect(user: %i[email password first_name last_name telegram_id telegram_user])
      end

      def athlete_params
        params.expect(athlete: %i[name male parkrun_code fiveverst_code runpark_code])
      end

      def link_user_to_athlete!
        if params[:athlete_id]
          @athlete = Athlete.find(params[:athlete_id])
          @athlete.update!(user: @user)
        else
          @athlete = @user.create_athlete!(athlete_params)
        end
      end
    end
  end
end
