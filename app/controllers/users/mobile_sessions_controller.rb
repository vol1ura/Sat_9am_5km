# frozen_string_literal: true

module Users
  class MobileSessionsController < ApplicationController
    before_action :authenticate_user!

    def destroy
      current_user.mobile_sessions.find(params.expect(:id)).revoke!
      redirect_to user_path, notice: t('users.mobile_access.revoked')
    end
  end
end
