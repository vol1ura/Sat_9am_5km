# frozen_string_literal: true

class PagesController < ApplicationController
  before_action :validate_page

  def show
    render template: "pages/#{page_name}"
  end

  private

  def page_name
    @page_name ||= params[:page]&.to_s&.delete_prefix('_') || 'index'
  end

  def validate_page
    return if Dir['app/views/pages/*'].any? { |f| f.include?("/#{page_name}.#{request.format.to_sym || 'html'}.") }

    render file: 'public/404.html', status: :not_found
  end
end
