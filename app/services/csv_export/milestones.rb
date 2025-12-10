# frozen_string_literal: true

module CsvExport
  class Milestones
    MILESTONES = [10, 25, 50, 100, 250, 500, 1000].freeze

    def initialize(event:)
      @event = event
    end

    def generate
      CSV.generate do |csv|
        csv << %w[id name total_runs runs_to_next_milestone next_run_milestone total_vols vols_to_next_milestone next_vol_milestone last_participation]
        
        dataset.each do |row|
          runs = row['results_count'].to_i
          vols = row['volunteering_count'].to_i
          
          next_run_m = next_milestone(runs)
          next_vol_m = next_milestone(vols)
          
          csv << [
            row['id'],
            row['name'],
            runs,
            next_run_m ? next_run_m - runs : nil,
            next_run_m,
            vols,
            next_vol_m ? next_vol_m - vols : nil,
            next_vol_m,
            row['last_date']&.strftime('%d.%m.%Y')
          ]
        end
      end
    end

    def filename
      "#{@event.code_name}_milestones_#{Time.zone.now.to_i}.csv"
    end

    private

    def next_milestone(current_count)
      MILESTONES.find { |m| m > current_count }
    end

    def dataset

      sql = <<~SQL
        WITH target_athletes AS (
          SELECT DISTINCT athlete_id FROM results 
          JOIN activities ON results.activity_id = activities.id 
          WHERE activities.event_id = :event_id AND activities.published = true
          UNION
          SELECT DISTINCT athlete_id FROM volunteers
          JOIN activities ON volunteers.activity_id = activities.id
          WHERE activities.event_id = :event_id AND activities.published = true
        ),
        global_results AS (
          SELECT athlete_id, COUNT(*) as cnt, MAX(activities.date) as last_date
          FROM results
          JOIN activities ON results.activity_id = activities.id
          WHERE activities.published = true
          AND athlete_id IN (SELECT athlete_id FROM target_athletes)
          GROUP BY athlete_id
        ),
        global_vols AS (
          SELECT athlete_id, COUNT(*) as cnt, MAX(activities.date) as last_date
          FROM volunteers
          JOIN activities ON volunteers.activity_id = activities.id
          WHERE activities.published = true
          AND athlete_id IN (SELECT athlete_id FROM target_athletes)
          GROUP BY athlete_id
        )
        SELECT 
          a.id, 
          a.name, 
          COALESCE(gr.cnt, 0) as results_count,
          COALESCE(gv.cnt, 0) as volunteering_count,
          GREATEST(gr.last_date, gv.last_date) as last_date
        FROM athletes a
        JOIN target_athletes ta ON a.id = ta.athlete_id
        LEFT JOIN global_results gr ON a.id = gr.athlete_id
        LEFT JOIN global_vols gv ON a.id = gv.athlete_id
        ORDER BY last_date DESC NULLS LAST
      SQL

      ActiveRecord::Base.connection.select_all(
        ActiveRecord::Base.send(:sanitize_sql_array, [sql, event_id: @event.id])
      )
    end
  end
end
