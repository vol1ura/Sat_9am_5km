# frozen_string_literal: true

module Users
  class AuthLinksController < ApplicationController
    def show
      user = User.find_by(auth_token: params[:token])
      auth_token = Users::AuthToken.new(user)

      if auth_token.valid?
        sign_in user
        auth_token.expire!

        redirect_to root_path, notice: t('views.greeting', name: user.first_name)
      else
        redirect_to new_user_session_path, alert: t('views.auth_link_invalid')
      end
    end
  end
end
