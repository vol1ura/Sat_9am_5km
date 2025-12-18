# frozen_string_literal: true

class CookieConsentsController < ApplicationController
  def create
    cookies.permanent[:policy_accepted] = true
    current_user.update!(policy_accepted: true) if user_signed_in?

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove('cookie-consent') }
      format.html { redirect_back_or_to root_path }
    end
  end
end
