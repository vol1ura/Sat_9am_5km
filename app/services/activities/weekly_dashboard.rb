# frozen_string_literal: true

module Activities
  class WeeklyDashboard < ApplicationService
    Chart = Data.define(:key, :id, :total, :series, :labels) do
      def empty?
        total.zero?
      end
    end

    def initialize(country_events:, chart:)
      @country_events = country_events
      @chart = chart.to_s
    end

    def call
      case @chart
      when 'participants' then participants_chart
      when 'gender' then gender_chart
      when 'volunteers' then volunteers_chart
      else raise ArgumentError, "Unknown dashboard chart: #{@chart}"
      end
    end

    private

    def participants_chart
      results = Result.where(activity_id: weekly_activity_ids)
      total = results.count
      first_runs = count_newbies(Result, results)
      personal_bests = [results.where(personal_best: true).count - first_runs, 0].max
      others = [total - first_runs - personal_bests, 0].max

      build_chart(
        total: total,
        slices: [
          [first_runs, t('newcomers_s95')],
          [personal_bests, t('personal_bests')],
          [others, t('others')],
        ],
      )
    end

    def gender_chart
      stats = Result.where(activity_id: weekly_activity_ids).left_joins(:athlete).group(:gender).count

      build_chart(
        total: stats.values.sum,
        slices: [
          [stats['male'].to_i, t('male')],
          [stats['female'].to_i, t('female')],
          [stats[nil].to_i, t('unknown')],
        ],
      )
    end

    def volunteers_chart
      volunteers = Volunteer.where(activity_id: weekly_activity_ids)
      total = volunteers.count
      first_time = count_newbies(Volunteer, volunteers)

      build_chart(
        total: total,
        slices: [
          [first_time, t('newcomers')],
          [[total - first_time, 0].max, t('others')],
        ],
      )
    end

    def build_chart(total:, slices:)
      series, labels = slices.each_with_object([[], []]) do |(value, label), (values, names)|
        next unless value.positive?

        values << value
        names << label
      end

      Chart.new(key: @chart, id: "#{@chart}-chart", total: total, series: series, labels: labels)
    end

    def weekly_activity_ids
      @weekly_activity_ids ||=
        Activity.published.joins(:event).where(event: @country_events, date: last_saturday..).select(:id)
    end

    def last_saturday
      today = Date.current
      today.saturday? ? today : today.prev_occurring(:saturday)
    end

    def count_newbies(model, current_ds)
      model
        .published
        .where(athlete_id: current_ds.select(:athlete_id))
        .group(:athlete_id)
        .having('count(athlete_id) = 1')
        .count
        .size
    end

    def t(key)
      I18n.t(key, scope: :'activities.dashboard')
    end
  end
end
