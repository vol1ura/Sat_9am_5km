class AddFlagsToResults < ActiveRecord::Migration[7.0]
  FLAGS_COLUMNS = %i[personal_best first_run]
  def up
    FLAGS_COLUMNS.each do |column|
      add_column :results, column, :boolean, null: false, default: false
    end

    Athlete.find_each do |athlete|
      results = athlete.results.published.includes(:activity).order(:date).to_a
      next if results.empty?

      best_result = results.shift
      best_result.update!(personal_best: true, first_run: true)
      activity_ids_list = [best_result.activity.event_id]

      results.each do |result|
        if best_result.total_time > result.total_time
          best_result = result
          result.update!(personal_best: true)
        end

        unless activity_ids_list.include?(result.activity.event_id)
          activity_ids_list << result.activity.event_id
          result.update!(first_run: true)
        end
      end
    end
  end

  def down
    FLAGS_COLUMNS.each { |column| remove_column :results, column }
  end
end
