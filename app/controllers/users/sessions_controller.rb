# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController


    # GET /resource/sign_in
    # def new
    #   super
    # end

    protected

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_in_params
      devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
    end
  end
end
