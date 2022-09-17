# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery

  def access_denied(_)
    message = t 'active_admin.access_denied.message'
    respond_to do |format|
      format.html { redirect_to root_path, alert: message }
      format.js { render js: "alert('#{message}')" }
    end
  end
end
