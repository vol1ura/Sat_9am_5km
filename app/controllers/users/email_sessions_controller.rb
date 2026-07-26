# frozen_string_literal: true

module Users
  class EmailSessionsController < ApplicationController
    def create
      email = params[:email]&.downcase&.strip
      user = User.find_by(email:)

      if user&.confirmed?
        Users::AuthToken.new(user).generate!
        AuthLinkMailer.login_link(user).deliver_later
        redirect_to new_user_session_path, notice: t('.link_sent')
      elsif !user
        redirect_to new_user_registration_path(user: { email: }), alert: t('.not_registered')
      else
        redirect_to new_user_confirmation_path(user: { email: }), alert: t('.unconfirmed')
      end
    end
  end
end
