# frozen_string_literal: true

class ScannerProcessingJob < ApplicationJob
  queue_as :critical

  def perform(activity_id, data)
    activity = Activity.find activity_id
    Result.without_auditing do
      activity.with_lock('FOR UPDATE NOWAIT') do
        data.each do |result_params|
          athlete = Athlete.find_or_scrape_by_code! result_params[:code].delete('A').to_i

          result = activity.results.find_or_initialize_by position: result_params[:position].delete('P').to_i
          result = activity.results.new result.as_json(only: %i[total_time position]) if result.athlete_id

          result.without_auditing { result.update! athlete: } unless result.athlete == athlete
        end
      end
    end
  rescue ActiveRecord::StatementInvalid
    self.class.set(wait: 1.second).perform_later activity_id, data
  end
end
