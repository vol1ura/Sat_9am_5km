# frozen_string_literal: true

class UserRegistrationsCsvExportJob < ApplicationJob
  queue_as :low

  SQL_QUERY = <<~SQL.squish
    SELECT
      DATE_TRUNC('month', users.created_at) AS month,
      COUNT(*) AS total_count,
      COUNT(*) FILTER (WHERE ec.code = 'ru' OR cc.code = 'ru') AS ru_count,
      COUNT(*) FILTER (WHERE ec.code = 'by' OR cc.code = 'by') AS by_count,
      COUNT(*) FILTER (WHERE ec.code = 'rs' OR cc.code = 'rs') AS rs_count,
      COUNT(*) FILTER (WHERE a.parkrun_code IS NOT NULL) AS parkrun_count,
      COUNT(*) FILTER (WHERE a.fiveverst_code IS NOT NULL) AS fiveverst_count,
      COUNT(*) FILTER (WHERE a.runpark_code IS NOT NULL) AS runpark_count
    FROM users
    LEFT JOIN athletes a ON a.user_id = users.id
    LEFT JOIN events e ON e.id = a.event_id
    LEFT JOIN clubs c ON c.id = a.club_id
    LEFT JOIN countries ec ON ec.id = e.country_id
    LEFT JOIN countries cc ON cc.id = c.country_id
    WHERE users.created_at >= ?
    GROUP BY DATE_TRUNC('month', users.created_at)
    ORDER BY month DESC
  SQL

  def perform(user_id, from_date = nil)
    @user = User.find user_id
    @from_date = from_date ? Date.parse(from_date) : 12.months.ago.beginning_of_month.to_date
    return unless @user.telegram_id

    tempfile = generate_csv

    Telegram::Notification::File.call(
      @user,
      file: tempfile,
      filename: "user_registrations_#{Time.zone.now.to_i}.csv",
      caption: "Отчёт по регистрациям пользователей с #{I18n.l(@from_date, format: :long)}",
    )
  rescue StandardError => e
    Rollbar.error e, user_id: @user.id
  ensure
    tempfile&.close
    tempfile&.unlink
  end

  private

  def generate_csv
    tempfile = Tempfile.new
    CSV.open(tempfile.path, 'w') do |csv|
      csv << %w[Month TotalNew Russia Belarus Serbia ParkrunID 5verstID RunParkID]
      User.find_by_sql([SQL_QUERY, @from_date]).each do |stats|
        csv << generate_row(stats)
      end
    end
    tempfile.rewind
    tempfile
  end

  def generate_row(stats)
    [
      I18n.l(stats.month, format: '%B %Y'),
      stats.total_count,
      stats.ru_count,
      stats.by_count,
      stats.rs_count,
      stats.parkrun_count,
      stats.fiveverst_count,
      stats.runpark_count,
    ]
  end
end
