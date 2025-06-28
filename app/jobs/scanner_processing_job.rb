# frozen_string_literal: true

class ScannerProcessingJob < ApplicationJob
  queue_as :critical

  def perform(activity_id, data)
    @activity = Activity.find activity_id
    return if @activity.published

    @activity.with_lock('FOR UPDATE NOWAIT') do
      data.each { |result_params| process_result result_params }
    end
  rescue ActiveRecord::StatementInvalid
    self.class.set(wait: 1.second).perform_later activity_id, data
  end

  private

  def process_result(result_params)
    athlete = Athlete.find_or_scrape_by_code! result_params[:code].delete('A').to_i
    result = @activity.results.find_or_initialize_by position: result_params[:position].delete('P').to_i
    if result.athlete_id
      return if result.athlete_id == athlete.id

      result = @activity.results.new result.as_json(only: %i[position total_time])
    end

    result.without_auditing do
      unless result.update(athlete:)
        message = alert_message result_params
        Telegram::Notification::ActivityAlertJob.perform_later @activity.id, message
        Rollbar.error 'Result processing failed', activity_id: @activity.id, message: message, errors: result.errors.inspect
      end
    end
  end

  def alert_message(result_params)
    <<~TEXT
      Внимание!
      В данных сканера содержатся ошибки, поэтому результат *#{result_params[:position]}* не может быть сохранён.
      Пожалуйста, проверьте позицию *#{result_params[:position]}*, а также участника с ID *#{result_params[:code]}* \
      на дублирование в протоколе и файлах сканера.
    TEXT
  end
end
