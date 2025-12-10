# frozen_string_literal: true

module CsvExport
  class ClubStats
    def initialize(event:, from_date: nil, to_date: nil)
      @event = event
      @from_date = from_date
      @to_date = to_date
    end

    def generate
      CSV.generate do |csv|
        csv << %w[club_name unique_athletes total_runs]
        
        dataset.each do |row|
          csv << [
            row['club_name'],
            row['unique_athletes'],
            row['total_runs']
          ]
        end
      end
    end

    def filename
      "#{@event.code_name}_club_stats_#{Time.zone.now.to_i}.csv"
    end

    private

    def dataset

      
      sql = <<~SQL
        SELECT 
          c.name as club_name, 
          COUNT(DISTINCT r.athlete_id) as unique_athletes, 
          COUNT(*) as total_runs
        FROM results r
        JOIN activities a ON r.activity_id = a.id
        JOIN athletes ath ON r.athlete_id = ath.id
        JOIN clubs c ON ath.club_id = c.id
        WHERE a.event_id = :event_id AND a.published = true
        #{date_condition}
        GROUP BY c.name
        ORDER BY total_runs DESC
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
      conds << "AND a.date >= :from_date" if @from_date
      conds << "AND a.date <= :to_date" if @to_date
      conds.join("\n")
    end
  end
end
