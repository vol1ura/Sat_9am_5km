# frozen_string_literal: true

class ApplicationController < ActionController::Base
  TOP_LEVEL_DOMAIN_MAPPING = {
    'rs' => :rs,
    'by' => :by,
  }.tap { |h| h.default = :ru }.freeze

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
    locale = I18n.available_locales.include?(top_level_domain) ? top_level_domain : I18n.default_locale

    I18n.with_locale(locale, &)
  end

  def find_country_events
    @country_events = Country.find_by(code: top_level_domain).events
  end

  def top_level_domain
    @top_level_domain ||= TOP_LEVEL_DOMAIN_MAPPING[request.host.split('.').last]
  end
end
