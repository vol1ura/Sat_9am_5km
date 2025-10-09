# frozen_string_literal: true

class ApplicationController < ActionController::Base
  around_action :switch_locale
  before_action :find_country_events

  def access_denied(_)
    message = t 'active_admin.access_denied.message'
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, alert: message }
      format.js { render js: "alert('#{message}')" }
    end
  end

  private

  def switch_locale(&)
    I18n.with_locale(current_locale, &)
  end

  def find_country_events
    @country_events = Event.in_country(top_level_domain)
  end

  def current_locale
    requested = params[:lang]&.to_s&.downcase&.to_sym
    if requested && I18n.available_locales.include?(requested)
      requested
    else
      domain_locale
    end
  end

  def domain_locale
    I18n.available_locales.find { |l| l == top_level_domain } || I18n.default_locale
  end

  def top_level_domain
    @top_level_domain ||= request.host.split('.').last.to_sym
  end

  def default_url_options
    super.merge(lang: current_locale == domain_locale ? nil : current_locale)
  end

  helper_method :top_level_domain, :domain_locale, :current_locale
end
