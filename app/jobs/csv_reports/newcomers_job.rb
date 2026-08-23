# frozen_string_literal: true

module CsvReports
  class NewcomersJob < BaseJob
    HEADERS = [
      'Участник',
      'Дата дебюта',
      'Локация дебюта',
      'Число волонтёрств до дебюта',
      'Число забегов на текущий момент',
      'Число волонтёрств на текущий момент',
      'Число суббот с момента дебюта',
    ].freeze

    SQL_QUERY = <<~SQL.squish
      WITH first_results AS (
        SELECT
          results.athlete_id,
          MIN(activities.date) AS debut_date
        FROM results
        INNER JOIN activities ON activities.id = results.activity_id
        WHERE activities.published = TRUE
          AND results.athlete_id IS NOT NULL
        GROUP BY results.athlete_id
      ),
      debuts AS (
        SELECT DISTINCT ON (first_results.athlete_id)
          first_results.athlete_id,
          first_results.debut_date,
          activities.event_id AS debut_event_id,
          events.name AS debut_location
        FROM first_results
        INNER JOIN results ON results.athlete_id = first_results.athlete_id
        INNER JOIN activities ON activities.id = results.activity_id
          AND activities.date = first_results.debut_date
          AND activities.published = TRUE
        INNER JOIN events ON events.id = activities.event_id
        ORDER BY first_results.athlete_id, activities.date, activities.id
      )
      SELECT
        athletes.id,
        athletes.name,
        debuts.debut_date,
        debuts.debut_location,
        (
          SELECT COUNT(*)
          FROM volunteers v
          INNER JOIN activities a ON a.id = v.activity_id
          WHERE v.athlete_id = athletes.id
            AND a.published = TRUE
            AND a.date < debuts.debut_date
        ) AS vol_before_debut,
        (
          SELECT COUNT(*)
          FROM results r
          INNER JOIN activities a ON a.id = r.activity_id
          WHERE r.athlete_id = athletes.id
            AND a.published = TRUE
            AND a.date >= debuts.debut_date
            AND a.date <= ?
        ) AS runs_since_debut,
        (
          SELECT COUNT(*)
          FROM volunteers v
          INNER JOIN activities a ON a.id = v.activity_id
          WHERE v.athlete_id = athletes.id
            AND a.published = TRUE
            AND a.date >= debuts.debut_date
            AND a.date <= ?
        ) AS vol_since_debut
      FROM debuts
      INNER JOIN athletes ON athletes.id = debuts.athlete_id
      WHERE debuts.debut_event_id = ?
        AND debuts.debut_date >= ?
        AND debuts.debut_date <= ?
      ORDER BY debuts.debut_date, athletes.name
    SQL

    def perform(event_id, user_id, from_date, till_date)
      @event = Event.find event_id
      @from_date = from_date ? Date.parse(from_date) : 1.year.ago.beginning_of_month.to_date
      @till_date = till_date ? Date.parse(till_date) : Time.zone.today
      @report_date = Time.zone.today

      notify(
        user_id,
        file: tempfile,
        filename: "#{@event.code_name}_newcomers_#{Time.zone.now.to_i}.csv",
        caption: "Отчёт по новичкам: #{@event.name} с #{I18n.l(@from_date)} по #{I18n.l(@till_date)}",
      )
    rescue StandardError => e
      Rollbar.error e, user_id:, event_id:
    ensure
      tempfile&.close
      tempfile&.unlink
    end

    private

    def tempfile
      @tempfile ||= generate_csv(dataset) { |row| csv_row(row) }
    end

    def dataset
      Athlete.find_by_sql(
        [
          SQL_QUERY,
          @report_date,
          @report_date,
          @event.id,
          @from_date,
          @till_date,
        ],
      )
    end

    def csv_row(row)
      debut_date = row.debut_date
      [
        row.name,
        I18n.l(debut_date),
        row.debut_location,
        row.vol_before_debut,
        row.runs_since_debut,
        row.vol_since_debut,
        saturdays_since(debut_date),
      ]
    end

    def saturdays_since(debut_date) = (debut_date..@report_date).count(&:saturday?)
  end
end
