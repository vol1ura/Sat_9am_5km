# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    before_action :unlock_dev_super_admin, only: :create

    # GET /resource/sign_in
    # def new
    #   super
    # end

    # POST /user/login
    def create
      super
    end

    # DELETE /user/logout
    # def destroy
    #   super
    # end

    protected

    # In development allow unlocking test super admin before sign in to avoid
    # "Your account is locked" during local testing when using quick-login buttons.
    def unlock_dev_super_admin
      return unless Rails.env.development?
      return unless params[:user].present? && params[:user][:email].present?

      email = params[:user][:email].to_s.downcase
      user = User.find_by(email: email)
      return unless user&.super_admin?

      # Reset lock flags so Devise will allow sign in
      begin
        user.update_columns(locked_at: nil, failed_attempts: 0)
      rescue StandardError => e
        Rails.logger.warn "Failed to unlock dev super admin: ", e.message
      end
    end

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_in_params
    #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
    # end
  end
end
