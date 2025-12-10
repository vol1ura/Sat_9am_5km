# frozen_string_literal: true

module CsvExport
  class Newcomers
    def initialize(event:, from_date: nil, to_date: nil)
      @event = event
      @from_date = from_date
      @to_date = to_date
    end

    def generate
      CSV.generate do |csv|
        csv << %w[id name first_run_date total_runs]
        
        dataset.each do |row|
          csv << [
            row['id'],
            row['name'],
            row['first_date'] ? Date.parse(row['first_date'].to_s).strftime('%d.%m.%Y') : nil,
            row['total_runs']
          ]
        end
      end
    end

    def filename
      "#{@event.code_name}_newcomers_#{Time.zone.now.to_i}.csv"
    end

    private

    def dataset
      sql = <<~SQL
        WITH correct_first_runs AS (
           SELECT DISTINCT ON (r.athlete_id)
        WITH correct_first_runs AS (
           SELECT DISTINCT ON (r.athlete_id)
             r.athlete_id,
             act.date as first_date,
             act.event_id as first_event_id
           FROM results r
           JOIN activities act ON r.activity_id = act.id
           WHERE act.published = true
           ORDER BY r.athlete_id, act.date ASC
        )
        SELECT 
          a.id,
          a.name,
          cfr.first_date,
          (SELECT COUNT(*) FROM results r2 JOIN activities a2 ON r2.activity_id = a2.id WHERE r2.athlete_id = a.id AND a2.published = true) as total_runs
        FROM correct_first_runs cfr
        JOIN athletes a ON cfr.athlete_id = a.id
        WHERE cfr.first_event_id = :event_id
        #{date_condition}
        ORDER BY cfr.first_date DESC
      SQL

      params = { event_id: @event.id }
      params[:from_date] = @from_date if @from_date
      params[:to_date] = @to_date if @to_date

      ActiveRecord::Base.connection.select_all(
        ActiveRecord::Base.send(:sanitize_sql_array, [sql, params])
      )
    end

    def date_condition
      conds = []
      conds << "AND cfr.first_date >= :from_date" if @from_date
      conds << "AND cfr.first_date <= :to_date" if @to_date
      conds.join("\n")
    end
  end
end
