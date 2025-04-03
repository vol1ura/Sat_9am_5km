# frozen_string_literal: true

class PagesController < ApplicationController
  ALLOWED_PAGES = %w[about rules support additional-events privacy-policy robots 5za5].freeze

  before_action :validate_page

  def show
    render template: "pages/#{page_name}"
  end

  private

  def page_name
    @page_name ||= params[:page].to_s
  end

  def validate_page
    render file: 'public/404.html', status: :not_found if ALLOWED_PAGES.exclude?(page_name)
  end
end
