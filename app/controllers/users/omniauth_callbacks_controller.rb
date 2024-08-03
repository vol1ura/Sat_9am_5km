# frozen_string_literal: true

module Users
  # https://github.com/heartcombo/devise#omniauth
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # GET|POST /users/auth/telegram/callback
    def telegram
      @user = User.find_by telegram_id: request.env['omniauth.auth']['uid']

      if @user
        sign_in_and_redirect @user, event: :authentication # this will throw if @user is not activated
        set_flash_message(:notice, :success, kind: 'Telegram') if is_navigational_format?
      else
        redirect_to new_user_registration_url
      end
    end

    def failure
      Rollbar.warn('OAuth error', params)
      redirect_to new_user_session_url, alert: t('.auth_error')
    end

    # GET|POST /resource/auth/telegram
    # def passthru
    #   super
    # end

    # protected

    # The path used when OmniAuth fails
    # def after_omniauth_failure_path_for(scope)
    #   super(scope)
    # end
  end
end
