# frozen_string_literal: true

module Users
  class MobileAccessController < ApplicationController
    before_action :authenticate_user!

    def create
      code = MobilePairingCode.generate_for!(current_user)
      redirect_to user_path, notice: t('users.mobile_access.generated'), flash: { mobile_pairing_code: code }
    end

    def destroy
      current_user.mobile_sessions.active.find_each(&:revoke!)
      redirect_to user_path, notice: t('users.mobile_access.revoked_all')
    end
  end
end
