# frozen_string_literal: true

class TimerProcessingJob < ApplicationJob
  queue_as :critical

  def perform(activity_id, data)
    activity = Activity.find activity_id

    Result.without_auditing do
      activity.with_lock('FOR UPDATE NOWAIT') do
        data.each do |result_params|
          results = activity.results.where position: result_params[:position]
          if results.empty?
            activity.results.create! position: result_params[:position], total_time: result_params[:total_time]
          else
            results.where(total_time: nil).update_all total_time: result_params[:total_time]
          end
        end
      end
    end
  rescue ActiveRecord::StatementInvalid
    self.class.set(wait: 1.second).perform_later activity_id, data
  end
end
