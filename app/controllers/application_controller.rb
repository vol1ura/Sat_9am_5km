# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery

  def access_denied(_)
    redirect_to root_path, alert: t('active_admin.access_denied.message')
  end
end
