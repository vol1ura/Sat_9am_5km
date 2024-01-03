# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :find_country_events
  around_action :switch_locale

  def access_denied(_)
    message = t 'active_admin.access_denied.message'
    respond_to do |format|
      format.html { redirect_to root_path, alert: message }
      format.js { render js: "alert('#{message}')" }
    end
  end

  private

  def switch_locale(&)
    I18n.with_locale(domain_locale, &)
  end

  def find_country_events
    @country_events = Event.in_country(domain_locale)
  end

  def domain_locale
    return @domain_locale if @domain_locale

    top_level_domain = request.host.split('.').last.to_sym
    @domain_locale = I18n.available_locales.find { |l| l == top_level_domain } || I18n.default_locale
  end
end
