# frozen_string_literal: true

module CsvReports
  class EventAthletesJob < BaseJob
    HEADERS = %w[
      ID
      Name
      ResultsCountOnEvent
      ResultsCount
      VolunteeringCountOnEvent
      VolunteeringCount
    ].freeze

    def perform(event_id, user_id, from_date, till_date)
      @event = Event.find event_id
      @from_date = Date.parse from_date if from_date
      @till_date = Date.parse till_date if till_date

      notify(
        user_id,
        file: tempfile,
        filename: "#{@event.code_name}_participants_#{Time.zone.now.to_i}.csv",
        caption: "Отчёт по участникам мероприятия: #{@event.name}",
      )
    rescue StandardError => e
      Rollbar.error e, user_id:, event_id:
    ensure
      tempfile&.close
      tempfile&.unlink
    end

    private

    def tempfile
      @tempfile ||= generate_csv(dataset) do |row|
        [row.id, row.name, row.res_event_count, row.res_total_count, row.vol_event_count, row.vol_total_count]
      end
    end

    def dataset
      Athlete
        .joins("LEFT JOIN (#{results_subquery.to_sql}) res ON res.athlete_id = athletes.id")
        .joins("LEFT JOIN (#{volunteering_subquery.to_sql}) vol ON vol.athlete_id = athletes.id")
        .where('res.event_count > 0 OR vol.event_count > 0')
        .select(
          'athletes.id,' \
          'athletes.name,' \
          'COALESCE(res.total_count, 0) AS res_total_count,' \
          'COALESCE(res.event_count, 0) AS res_event_count,' \
          'COALESCE(vol.total_count, 0) AS vol_total_count,' \
          'COALESCE(vol.event_count, 0) AS vol_event_count',
        )
    end

    def subquery_for(model)
      scope = model.published.where.not(athlete_id: nil).group(:athlete_id)
      scope = scope.where(activity: { date: date_range }) if date_range
      scope
    end

    def results_subquery
      subquery_for(Result).select(
        "athlete_id, COUNT(*) AS total_count, COUNT(*) FILTER (WHERE event_id = #{@event.id}) AS event_count",
      )
    end

    def volunteering_subquery
      subquery_for(Volunteer).select(
        "athlete_id, COUNT(*) AS total_count, COUNT(*) FILTER (WHERE event_id = #{@event.id}) AS event_count",
      )
    end
  end
end
