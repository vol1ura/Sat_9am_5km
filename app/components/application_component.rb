# frozen_string_literal: true

class ApplicationComponent < ViewComponent::Base
  include ApplicationHelper
  include NavigationHelper

  delegate :user_signed_in?, :current_user, :top_level_domain, :domain_locale, :current_locale, to: :helpers
end
