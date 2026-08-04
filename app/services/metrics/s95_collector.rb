# frozen_string_literal: true

module Metrics
  class S95Collector < ApplicationService
    RECENT_ACTIVITY_WINDOW = 12.weeks
    PROMETHEUS_LABEL_ESCAPES = {
      '\\' => '\\\\',
      '"' => '\"',
      "\n" => '\n',
    }.freeze

    def call
      @metrics = []

      collect_event_metrics
      collect_activity_metrics
      collect_volunteer_metrics

      @metrics.join("\n")
    end

    private

    def collect_event_metrics
      Event.active
        .joins(:country)
        .reorder(nil)
        .group('countries.code')
        .count
        .each do |country_code, count|
        counter('s95_events_total', { country: country_code, active: 'true' }, count)
      end
    end

    def collect_activity_metrics
      collect_activity_total_metrics
      collect_activity_result_metrics
    end

    def collect_activity_total_metrics
      Activity.published
        .joins(event: :country)
        .reorder(nil)
        .group('events.code_name', 'countries.code')
        .count
        .each do |(event_code, country_code), count|
        counter('s95_activities_total', { event: event_code, country: country_code, published: 'true' }, count)
      end
    end

    def collect_activity_result_metrics
      recent_activity_result_counts.each do |row|
        labels = { event: row.event_code, activity_date: row.activity_date }
        counter('s95_activity_results_total', labels, row.results_count)
        counter('s95_activity_first_runs_total', labels, row.first_runs_count)
        counter('s95_activity_personal_bests_total', labels, row.personal_bests_count)
        gauge('s95_activity_average_time_seconds', labels, row.average_time.to_i)
      end
    end

    def recent_activity_result_counts
      Result.published
        .joins(activity: :event)
        .reorder(nil)
        .where(activity: { date: recent_activity_range })
        .select(
          'events.code_name AS event_code',
          'activity.date AS activity_date',
          'COUNT(results.id) AS results_count',
          'SUM(CASE WHEN results.first_run THEN 1 ELSE 0 END) AS first_runs_count',
          'SUM(CASE WHEN results.personal_best THEN 1 ELSE 0 END) AS personal_bests_count',
          'AVG(results.total_time) AS average_time',
        )
        .group('events.code_name', 'activity.date')
    end

    def collect_volunteer_metrics
      collect_activity_volunteer_metrics
      collect_volunteer_role_metrics
    end

    def collect_activity_volunteer_metrics
      Volunteer.published
        .joins(activity: :event)
        .reorder(nil)
        .where(activity: { date: recent_activity_range })
        .group('events.code_name', 'activity.date')
        .count
        .each do |(event_code, activity_date), count|
        counter('s95_activity_volunteers_total', { event: event_code, activity_date: activity_date }, count)
      end
    end

    def collect_volunteer_role_metrics
      Volunteer.published
        .joins(activity: :event)
        .reorder(nil)
        .where(activity: { date: recent_activity_range })
        .group('events.code_name', 'activity.date', 'volunteers.role')
        .count
        .each do |(event_code, activity_date, role), count|
        counter(
          's95_volunteers_by_role_total',
          { event: event_code, activity_date: activity_date, role: Volunteer.roles.key(role) || role },
          count,
        )
      end
    end

    def recent_activity_range
      RECENT_ACTIVITY_WINDOW.ago.to_date..
    end

    def counter(name, labels, value)
      metric(name, labels, value)
    end

    def gauge(name, labels, value)
      metric(name, labels, value)
    end

    def metric(name, labels, value)
      @metrics << "#{name}{#{format_labels(labels)}} #{value}"
    end

    def format_labels(labels)
      labels.map { |key, value| "#{key}=\"#{escape_label(value)}\"" }.join(',')
    end

    def escape_label(value)
      value.to_s.gsub(/\\|"|\n/) { |char| PROMETHEUS_LABEL_ESCAPES.fetch(char) }
    end
  end
end
