# frozen_string_literal: true

module CsvReports
  class UserRegistrationsJob < BaseJob
    HEADERS = %w[Date TotalNew Russia Belarus Serbia ParkrunID 5verstID RunParkID WithResult WithVolunteering].freeze

    SQL_QUERY = <<~SQL.squish
      SELECT
        users.created_at::date AS date,
        COUNT(*) AS total_count,
        COUNT(*) FILTER (WHERE ec.code = 'ru' OR cc.code = 'ru') AS ru_count,
        COUNT(*) FILTER (WHERE ec.code = 'by' OR cc.code = 'by') AS by_count,
        COUNT(*) FILTER (WHERE ec.code = 'rs' OR cc.code = 'rs') AS rs_count,
        COUNT(*) FILTER (WHERE a.parkrun_code IS NOT NULL) AS parkrun_count,
        COUNT(*) FILTER (WHERE a.fiveverst_code IS NOT NULL) AS fiveverst_count,
        COUNT(*) FILTER (WHERE a.runpark_code IS NOT NULL) AS runpark_count,
        COUNT(*) FILTER (
          WHERE EXISTS (
            SELECT 1
            FROM results r
            INNER JOIN activities ar ON ar.id = r.activity_id AND ar.published = true
            WHERE r.athlete_id = a.id
          )
        ) AS with_results_count,
        COUNT(*) FILTER (
          WHERE EXISTS (
            SELECT 1
            FROM volunteers v
            INNER JOIN activities av ON av.id = v.activity_id AND av.published = true
            WHERE v.athlete_id = a.id
          )
        ) AS with_volunteering_count
      FROM users
      LEFT JOIN athletes a ON a.user_id = users.id
      LEFT JOIN events e ON e.id = a.event_id
      LEFT JOIN clubs c ON c.id = a.club_id
      LEFT JOIN countries ec ON ec.id = e.country_id
      LEFT JOIN countries cc ON cc.id = c.country_id
      WHERE users.created_at::date >= ? AND users.created_at::date <= ?
      GROUP BY users.created_at::date
      ORDER BY date DESC
    SQL

    def perform(user_id, from_date, till_date)
      @from_date = from_date ? Date.parse(from_date) : 1.year.ago.beginning_of_month.to_date
      @till_date = till_date ? Date.parse(till_date) : Time.zone.today
      tempfile = generate_csv(User.find_by_sql([SQL_QUERY, @from_date, @till_date])) { |stats| generate_row(stats) }

      notify(
        user_id,
        file: tempfile,
        filename: "user_registrations_#{Time.zone.now.to_i}.csv",
        caption: "Отчёт по регистрациям пользователей с #{I18n.l(@from_date)} по #{I18n.l(@till_date)}",
      )
    rescue StandardError => e
      Rollbar.error e, user_id:
    ensure
      tempfile&.close
      tempfile&.unlink
    end

    private

    def generate_row(stats)
      %i[
        date total_count ru_count by_count rs_count
        parkrun_count fiveverst_count runpark_count
        with_results_count with_volunteering_count
      ].map { stats.send it }
    end
  end
end
