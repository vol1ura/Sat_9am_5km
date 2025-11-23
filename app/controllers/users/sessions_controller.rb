# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController


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


    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_in_params
    #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
    # end
  end
end
