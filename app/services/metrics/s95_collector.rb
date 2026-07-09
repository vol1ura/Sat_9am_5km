# frozen_string_literal: true

module Metrics
  # rubocop:disable Metrics/ClassLength, Metrics/MethodLength, Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  class S95Collector < ApplicationService
    TTL = 5.minutes

    def call
      @data = {}
      collect_all_metrics
      format_metrics
    end

    private

    def collect_all_metrics
      collect_event_metrics
      collect_activity_metrics
      collect_athlete_metrics
      collect_volunteer_metrics
      collect_community_metrics
      collect_location_health
    end

    def collect_event_metrics
      Event.active.each do |event|
        @data[:events_total] ||= {}
        country_code = event.country.code
        next if @data[:events_total][country_code]

        @data[:events_total][country_code] = { active: event.active.to_s }
      end
    end

    def collect_activity_metrics
      Activity.published.includes(:event).find_each do |activity|
        collect_activity_metric(activity)
      end
    end

    def collect_activity_metric(activity)
      event_code = activity.event.code_name
      country_code = activity.event.country.code
      date_str = activity.date.to_s
      published_results = activity.results.published

      @data[:activities_total] ||= {}
      @data[:activities_total][event_code] ||= {}
      @data[:activities_total][event_code][country_code] = { published: activity.published.to_s }

      @data[:activity_results_total] ||= {}
      @data[:activity_results_total][event_code] ||= {}
      @data[:activity_results_total][event_code][date_str] = published_results.count

      @data[:activity_volunteers_total] ||= {}
      @data[:activity_volunteers_total][event_code] ||= {}
      @data[:activity_volunteers_total][event_code][date_str] = activity.volunteers.published.count

      @data[:activity_first_runs_total] ||= {}
      @data[:activity_first_runs_total][event_code] ||= {}
      @data[:activity_first_runs_total][event_code][date_str] = published_results.where(first_run: true).count

      @data[:activity_personal_bests_total] ||= {}
      @data[:activity_personal_bests_total][event_code] ||= {}
      @data[:activity_personal_bests_total][event_code][date_str] =
        published_results.where(personal_best: true).count

      @data[:activity_average_time_seconds] ||= {}
      @data[:activity_average_time_seconds][event_code] ||= {}
      @data[:activity_average_time_seconds][event_code][date_str] = calculate_average_time(activity)

      @data[:activity_median_time_seconds] ||= {}
      @data[:activity_median_time_seconds][event_code] ||= {}
      @data[:activity_median_time_seconds][event_code][date_str] = calculate_median_time(activity)

      @data[:activity_best_time_seconds] ||= {}
      @data[:activity_best_time_seconds][event_code] ||= {}
      @data[:activity_best_time_seconds][event_code][date_str] = calculate_best_time(activity)

      @data[:activity_pb_ratio] ||= {}
      @data[:activity_pb_ratio][event_code] ||= {}
      @data[:activity_pb_ratio][event_code][date_str] = calculate_pb_ratio(activity)

      @data[:activity_first_run_ratio] ||= {}
      @data[:activity_first_run_ratio][event_code] ||= {}
      @data[:activity_first_run_ratio][event_code][date_str] = calculate_first_run_ratio(activity)

      @data[:activity_correct] ||= {}
      @data[:activity_correct][event_code] ||= {}
      @data[:activity_correct][event_code][date_str] = activity.correct? ? 1 : 0

      @data[:activity_has_results] ||= {}
      @data[:activity_has_results][event_code] ||= {}
      @data[:activity_has_results][event_code][date_str] = published_results.exists? ? 1 : 0

      @data[:activity_published] ||= {}
      @data[:activity_published][event_code] ||= {}
      @data[:activity_published][event_code][date_str] = activity.published ? 1 : 0
    end

    def collect_athlete_metrics
      Event.active.find_each do |event|
        @data[:athletes_total] ||= {}
        @data[:athletes_total][event.code_name] ||= {}
        @data[:athletes_total][event.code_name][event.country.code] = event.athletes.count

        @data[:athletes_with_user_total] ||= {}
        @data[:athletes_with_user_total][event.code_name] = event.athletes.where.not(user_id: nil).count

        @data[:athletes_with_gender_total] ||= {}
        @data[:athletes_with_gender_total][event.code_name] ||= {}
        @data[:athletes_with_gender_total][event.code_name]['male'] =
          event.athletes.where(gender: 'male').count
        @data[:athletes_with_gender_total][event.code_name]['female'] =
          event.athletes.where(gender: 'female').count

        @data[:athletes_with_external_code_total] ||= {}
        @data[:athletes_with_external_code_total]['parkrun'] = Athlete.where.not(parkrun_code: nil).count
        @data[:athletes_with_external_code_total]['parkzhrun'] = Athlete.where.not(parkzhrun_code: nil).count
        @data[:athletes_with_external_code_total]['fiveverst'] = Athlete.where.not(fiveverst_code: nil).count
        @data[:athletes_with_external_code_total]['runpark'] = Athlete.where.not(runpark_code: nil).count

        @data[:athletes_going_to_event_total] ||= {}
        @data[:athletes_going_to_event_total][event.code_name] = event.going_athletes.count
      end
    end

    def collect_volunteer_metrics
      Activity.published.includes(:event).find_each do |activity|
        event_code = activity.event.code_name
        date_str = activity.date.to_s

        @data[:volunteers_total] ||= {}
        @data[:volunteers_total][event_code] ||= {}
        @data[:volunteers_total][event_code][date_str] = activity.volunteers.published.count

        @data[:volunteers_by_role_total] ||= {}
        @data[:volunteers_by_role_total][event_code] ||= {}
        @data[:volunteers_by_role_total][event_code][date_str] ||= {}
        activity.volunteers.published.group(:role).count.each do |role, count|
          @data[:volunteers_by_role_total][event_code][date_str][role] = count
        end

        @data[:unique_volunteers_total] ||= {}
        @data[:unique_volunteers_total][event_code] = calculate_unique_volunteers(activity.event)

        @data[:volunteer_roles_covered_total] ||= {}
        @data[:volunteer_roles_covered_total][event_code] ||= {}
        @data[:volunteer_roles_covered_total][event_code][date_str] =
          activity.volunteers.published.pluck(:role).uniq.count

        @data[:volunteer_position_coverage_ratio] ||= {}
        @data[:volunteer_position_coverage_ratio][event_code] ||= {}
        @data[:volunteer_position_coverage_ratio][event_code][date_str] = calculate_position_coverage(activity)

        @data[:volunteer_bus_factor] ||= {}
        @data[:volunteer_bus_factor][event_code] = calculate_volunteer_bus_factor(activity.event)
      end

      @data[:active_community_total] ||= {}
      Event.active.find_each do |event|
        @data[:active_community_total][event.code_name] = calculate_active_community(event)
      end
    end

    def collect_community_metrics
      Event.active.find_each do |event|
        @data[:unique_athletes_total] ||= {}
        @data[:unique_athletes_total][event.code_name] = calculate_unique_athletes(event)

        @data[:returning_athletes_total] ||= {}
        @data[:returning_athletes_total][event.code_name] = calculate_returning_athletes(event)

        @data[:sleeping_athletes_total] ||= {}
        @data[:sleeping_athletes_total][event.code_name] = calculate_sleeping_athletes(event)
      end
    end

    def collect_location_health
      Event.active.find_each do |event|
        @data[:location_health_score] ||= {}
        @data[:location_health_score][event.code_name] = LocationHealthCalculator.call(event)
      end
    end

    def calculate_average_time(activity)
      activity.results.published.where.not(total_time: nil).average(:total_time).to_i
    end

    def calculate_median_time(activity)
      results = activity.results.published.where.not(total_time: nil).order(:total_time)
      count = results.count
      return 0 if count.zero?

      mid = count / 2
      if count.odd?
        results.offset(mid).first&.total_time || 0
      else
        (results.offset(mid - 1).first&.total_time.to_f + results.offset(mid).first&.total_time.to_f) / 2
      end.to_i
    end

    def calculate_best_time(activity)
      best_times = {}
      activity.results.published
        .where.not(total_time: nil)
        .group(:athlete_id)
        .minimum(:total_time).each do |athlete_id, time|
        athlete = Athlete.find_by(id: athlete_id)
        next unless athlete

        gender = athlete.gender || 'unknown'
        best_times[gender] ||= []
        best_times[gender] << time
      end

      best_times.transform_values { |times| times.min || 0 }
    end

    def calculate_pb_ratio(activity)
      total = activity.results.published.count
      return 0 if total.zero?

      activity.results.published.where(personal_best: true).count.to_f / total
    end

    def calculate_first_run_ratio(activity)
      total = activity.results.published.count
      return 0 if total.zero?

      activity.results.published.where(first_run: true).count.to_f / total
    end

    def calculate_position_coverage(activity)
      positions = activity.event.volunteering_positions.count
      covered = activity.volunteers.published.pluck(:role).uniq.count
      return 0 if positions.zero?

      covered.to_f / positions
    end

    def calculate_volunteer_bus_factor(event)
      VolunteerBusFactorCalculator.call(event)
    end

    def calculate_unique_volunteers(event)
      Volunteer.joins(:activity)
        .where(activity: { event: event, published: true })
        .distinct.count(:athlete_id)
    end

    def calculate_active_community(event)
      activity_ids = Activity.published.where(event:).select(:id)
      result_athlete_ids = Result.where(activity: activity_ids).pluck(:athlete_id)
      volunteer_athlete_ids = Volunteer.where(activity: activity_ids).pluck(:athlete_id)
      (result_athlete_ids + volunteer_athlete_ids).compact.uniq.count
    end

    def calculate_unique_athletes(event)
      activity_ids = Activity.published.where(event:).select(:id)
      Result.where(activity: activity_ids).select(:athlete_id).distinct.count
    end

    def calculate_returning_athletes(event)
      activity_ids = Activity.published.where(event:).select(:id)
      Result.where(activity: activity_ids).group(:athlete_id).having('COUNT(*) > 1').count.count
    end

    def calculate_sleeping_athletes(event)
      total_athletes = event.athletes.count
      active = calculate_unique_athletes(event)
      total_athletes - active
    end

    def format_metrics
      metrics = []

      format_counter(metrics, 's95_events_total', @data[:events_total], %w[country active])
      format_counter(metrics, 's95_activities_total', @data[:activities_total], %w[event country published])
      format_counter(metrics, 's95_activity_results_total', @data[:activity_results_total], %w[event activity_date])
      format_counter(metrics, 's95_activity_volunteers_total', @data[:activity_volunteers_total], %w[event activity_date])
      format_counter(metrics, 's95_activity_first_runs_total', @data[:activity_first_runs_total], %w[event activity_date])
      format_counter(
        metrics,
        's95_activity_personal_bests_total',
        @data[:activity_personal_bests_total],
        %w[event activity_date],
      )
      format_counter(metrics, 's95_athletes_total', @data[:athletes_total], %w[event country])
      format_counter(metrics, 's95_athletes_with_user_total', @data[:athletes_with_user_total], %w[event])
      format_counter(metrics, 's95_athletes_with_gender_total', @data[:athletes_with_gender_total], %w[event gender])
      format_counter(
        metrics,
        's95_athletes_with_external_code_total',
        @data[:athletes_with_external_code_total],
        %w[source],
      )
      format_counter(metrics, 's95_athletes_going_to_event_total', @data[:athletes_going_to_event_total], %w[event])
      format_gauge(
        metrics,
        's95_activity_average_time_seconds',
        @data[:activity_average_time_seconds],
        %w[event activity_date],
      )
      format_gauge(
        metrics,
        's95_activity_median_time_seconds',
        @data[:activity_median_time_seconds],
        %w[event activity_date],
      )
      format_gauge(
        metrics,
        's95_activity_best_time_seconds',
        @data[:activity_best_time_seconds],
        %w[event activity_date gender],
      )
      format_gauge(metrics, 's95_activity_pb_ratio', @data[:activity_pb_ratio], %w[event activity_date])
      format_gauge(metrics, 's95_activity_first_run_ratio', @data[:activity_first_run_ratio], %w[event activity_date])
      format_gauge(metrics, 's95_activity_correct', @data[:activity_correct], %w[event activity_date])
      format_gauge(metrics, 's95_volunteers_total', @data[:volunteers_total], %w[event activity_date])
      format_counter(
        metrics,
        's95_volunteers_by_role_total',
        @data[:volunteers_by_role_total],
        %w[event activity_date role],
      )
      format_counter(metrics, 's95_unique_volunteers_total', @data[:unique_volunteers_total], %w[event window])
      format_gauge(
        metrics,
        's95_volunteer_roles_covered_total',
        @data[:volunteer_roles_covered_total],
        %w[event activity_date],
      )
      format_gauge(
        metrics,
        's95_volunteer_position_coverage_ratio',
        @data[:volunteer_position_coverage_ratio],
        %w[event activity_date],
      )
      format_gauge(metrics, 's95_volunteer_bus_factor', @data[:volunteer_bus_factor], %w[event])
      format_counter(metrics, 's95_active_community_total', @data[:active_community_total], %w[event window])
      format_counter(metrics, 's95_unique_athletes_total', @data[:unique_athletes_total], %w[event window])
      format_counter(metrics, 's95_returning_athletes_total', @data[:returning_athletes_total], %w[event window])
      format_counter(metrics, 's95_sleeping_athletes_total', @data[:sleeping_athletes_total], %w[event window])
      format_gauge(metrics, 's95_location_health_score', @data[:location_health_score], %w[event])
      format_gauge(metrics, 's95_activity_has_results', @data[:activity_has_results], %w[event activity_date])
      format_gauge(metrics, 's95_activity_published', @data[:activity_published], %w[event activity_date])

      metrics.join("\n")
    end

    def format_counter(metrics, name, data, labels)
      return unless data

      data.each do |key, value|
        if value.is_a?(Hash)
          value.each do |key2, value2|
            if value2.is_a?(Hash)
              value2.each do |key3, final_value|
                labels_str = format_labels(labels, [key, key2, key3])
                metrics << format_metric(name, final_value, labels_str)
              end
            else
              labels_str = format_labels(labels, [key, key2])
              metrics << format_metric(name, value2, labels_str)
            end
          end
        else
          labels_str = format_labels(labels, [key])
          metrics << format_metric(name, value, labels_str)
        end
      end
    end

    def format_gauge(metrics, name, data, labels)
      return unless data

      data.each do |key, value|
        if value.is_a?(Hash)
          value.each do |key2, value2|
            if value2.is_a?(Hash)
              value2.each do |key3, final_value|
                labels_str = format_labels(labels, [key, key2, key3])
                metrics << format_metric(name, final_value, labels_str)
              end
            else
              labels_str = format_labels(labels, [key, key2])
              metrics << format_metric(name, value2, labels_str)
            end
          end
        else
          labels_str = format_labels(labels, [key])
          metrics << format_metric(name, value, labels_str)
        end
      end
    end

    def format_labels(labels, values)
      return '' if labels.empty? || values.empty?

      labels.zip(values).map { |l, v| "#{l}=\"#{v}\"" }.join(',')
    end

    def format_metric(name, value, labels_str)
      if labels_str.empty?
        "#{name} #{value}"
      else
        "#{name}{#{labels_str}} #{value}"
      end
    end
  end
  # rubocop:enable Metrics/ClassLength, Metrics/MethodLength, Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
end
