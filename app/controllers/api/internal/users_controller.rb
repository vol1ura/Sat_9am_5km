# frozen_string_literal: true

module API
  module Internal
    class UsersController < ApplicationController
      def auth_link
        user = User.find(params.expect(:user_id))
        Users::AuthToken.new(user).generate!

        render json: { link: auth_link_url(token: user.auth_token, host: "s95.#{params[:domain]}") }
      end
    end
  end
end
