# frozen_string_literal: true

module Users
  class EmailSessionsController < ApplicationController
    def create
      user = User.find_by(email: params[:email]&.downcase&.strip)

      if user&.confirmed?
        Users::AuthToken.new(user).generate!
        AuthLinkMailer.login_link(user).deliver_later
      end

      redirect_to new_user_session_path, notice: t('.link_sent')
    end
  end
end
