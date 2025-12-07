# frozen_string_literal: true

class PagesController < ApplicationController
  ALLOWED_PAGES = %w[about feedback joining rules support additional-events privacy-policy robots 5za5 donor].freeze
  MAX_FEEDBACK_SIZE = 2000

  before_action :validate_page, only: :show

  layout :page_layout

  def index
    @local_events = Event.active.in_country(top_level_domain).unscope(:order)
    @next_saturday = Date.tomorrow.next_week.prev_week(:saturday)
    @last_saturday = @next_saturday - 7.days
    @weekly_stats = calculate_weekly_stats
    @jubilee_events =
      Activity
        .where(event: @local_events.without_friends, published: true, date: ...@next_saturday)
        .group(:event).order(count_all: :desc).count.filter_map do |event, activities_count|
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

    if params[:contact].blank? && message.present? && message.length <= MAX_FEEDBACK_SIZE
      NotificationMailer.with(message: message, user_id: current_user&.id).feedback.deliver_later
      redirect_to page_path(page: 'feedback'), notice: t('.sent')
    else
      redirect_to page_path(page: 'feedback'), alert: t('.error')
    end
  end

  def app
    send_file 'public/app-release.apk', type: 'application/vnd.android.package-archive', disposition: 'attachment'
  end

  private

  def page_name
    @page_name ||= params[:page].to_s
  end

  def validate_page
    render file: 'public/404.html', status: :not_found if ALLOWED_PAGES.exclude?(page_name)
  end

  def page_layout
    params[:action] == 'index' || page_name == 'donor' ? 'home' : 'application'
  end

  def calculate_weekly_stats
    activities = Activity.where(event: @local_events, published: true, date: @last_saturday)
                         .includes(:results, :volunteers)
    return nil if activities.empty?

    participants_data = calculate_participants(activities)
    
    {
      total_participants: participants_data[:total],
      newcomers: participants_data[:newcomers],
      newcomers_percentage: calculate_percentage(participants_data[:newcomers], participants_data[:total]),
      updated_at: @last_saturday
    }
  end

  def calculate_participants(activities)
    total = 0
    newcomers = 0

    activities.each do |activity|
      participants = activity.participants
      total += participants.count
      newcomers += count_newcomers(participants)
    end

    { total: total, newcomers: newcomers }
  end

  def count_newcomers(participants)
    participants.count do |athlete|
      first_participation_date(athlete) == @last_saturday
    end
  end

  def first_participation_date(athlete)
    first_result = athlete.results.published.minimum(:date)
    first_volunteer = athlete.volunteers.joins(:activity)
                             .where(activity: { published: true })
                             .minimum(:date)
    [first_result, first_volunteer].compact.min
  end

  def calculate_percentage(part, total)
    return 0 unless total.positive?
    (part.to_f / total * 100).round(1)
  end
end
