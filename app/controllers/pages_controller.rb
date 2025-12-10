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
    latest_update = Activity.where(published: true).maximum(:updated_at)
    cache_key = "weekly_stats/#{top_level_domain}/#{@last_saturday}/#{latest_update}"

    Rails.cache.fetch(cache_key) do
      activities = Activity.where(event: @local_events, published: true, date: @last_saturday)

      stats = { updated_at: @last_saturday }

      if activities.empty?
        stats.merge!(
          total_participants: nil,
          newcomers: nil,
          newcomers_percentage: nil
        )
      else
        participants_data = calculate_participants_data(activities)
        stats.merge!(
          total_participants: participants_data[:total],
          newcomers: participants_data[:newcomers],
          newcomers_percentage: calculate_percentage(participants_data[:newcomers], participants_data[:total])
        )
      end

      stats
    end
  end

  def calculate_participants_data(activities)
    activity_ids = activities.pluck(:id)
    

    total_count = activities.sum { |a| a.participants.count }
  
    newcomers_count = ActiveRecord::Base.connection.select_value(<<~SQL.squish)
      WITH current_participants AS (
        SELECT DISTINCT athlete_id FROM results WHERE activity_id IN (#{activity_ids.join(',')}) AND athlete_id IS NOT NULL
        UNION
        SELECT DISTINCT athlete_id FROM volunteers WHERE activity_id IN (#{activity_ids.join(',')}) AND athlete_id IS NOT NULL
      ),
      veterans AS (
        SELECT DISTINCT r.athlete_id FROM results r
        JOIN activities a ON r.activity_id = a.id
        WHERE r.athlete_id IN (SELECT athlete_id FROM current_participants)
          AND a.published = true AND a.date < '#{@last_saturday}'
        UNION
        SELECT DISTINCT v.athlete_id FROM volunteers v
        JOIN activities a ON v.activity_id = a.id
        WHERE v.athlete_id IN (SELECT athlete_id FROM current_participants)
          AND a.published = true AND a.date < '#{@last_saturday}'
      )
      SELECT COUNT(*) FROM current_participants cp
      WHERE cp.athlete_id NOT IN (SELECT athlete_id FROM veterans)
    SQL

    { total: total_count, newcomers: newcomers_count.to_i }
  end

  def calculate_percentage(part, total)
    return 0 unless total.positive?
    (part.to_f / total * 100).round(1)
  end
end
