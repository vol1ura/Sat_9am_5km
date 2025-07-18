# frozen_string_literal: true

class PagesController < ApplicationController
  ALLOWED_PAGES = %w[about feedback joining rules support additional-events privacy-policy robots 5za5].freeze
  MAX_FEEDBACK_SIZE = 950

  before_action :validate_page, only: :show

  layout 'home', only: [:index]

  def index
    @local_events = Event.in_country(top_level_domain).unscope(:order)
    @next_saturday = Date.tomorrow.next_week.prev_week(:saturday)
    @jubilee_events =
      Activity
        .where(event: @local_events.without_friends, published: true, date: ...@next_saturday)
        .group(:event).count.filter_map do |event, activities_count|
          activity_number = activities_count.next
          next unless (activity_number <= 50 && (activity_number % 10).zero?) || (activity_number % 100).zero?

          [event, activity_number]
        end
    @funrun_badges =
      Badge
        .includes(:image_attachment)
        .funrun_kind
        .where(received_date: @next_saturday)
        .where("info->>'country_code' IS NULL OR info->>'country_code' = ?", top_level_domain)
  end

  def show
    render template: "pages/#{page_name}"
  end

  def submit_feedback
    message = params[:message].to_s

    if message.present? && message.length <= MAX_FEEDBACK_SIZE
      NotificationMailer.with(message: message, user_id: current_user&.id).feedback.deliver_later
      redirect_to page_path(page: 'feedback'), notice: t('.sent')
    else
      redirect_to page_path(page: 'feedback'), alert: t('.error')
    end
  end

  private

  def page_name
    @page_name ||= params[:page].to_s
  end

  def validate_page
    render file: 'public/404.html', status: :not_found if ALLOWED_PAGES.exclude?(page_name)
  end
end
