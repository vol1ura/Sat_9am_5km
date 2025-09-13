# frozen_string_literal: true

class ArticlesController < ApplicationController
  ALLOWED_PAGES = %w[first-run].freeze

  before_action :validate_page, only: :show

  def index; end

  def show
    render template: "articles/#{page_name}"
  end

  private

  def page_name
    @page_name ||= params[:page].to_s
  end

  def validate_page
    render file: 'public/404.html', status: :not_found if ALLOWED_PAGES.exclude?(page_name)
  end
end
