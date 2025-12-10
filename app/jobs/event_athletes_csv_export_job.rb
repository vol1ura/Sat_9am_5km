# frozen_string_literal: true

class EventAthletesCsvExportJob < ApplicationJob
  queue_as :low

  def perform(event_id, user_id, from_date = nil)
    @event = Event.find event_id
    @user = User.find user_id
    @from_date = (Date.parse(from_date) rescue nil) if from_date
    return unless @user.telegram_id

    exporter = CsvExport::EventAthletes.new(event: @event, from_date: @from_date)
    
    tempfile = Tempfile.new(['export', '.csv'])
    tempfile.write(exporter.generate)
    tempfile.rewind

    Telegram::Bot.call 'sendDocument', form_data: multipart_form_data(tempfile, exporter.filename)
  rescue StandardError => e
    Rollbar.error e, user_id: @user.id, event_id: @event.id
  ensure
    tempfile&.close
    tempfile&.unlink
  end

  private

  def multipart_form_data(file, filename)
    [
      [
        'document',
        file,
        {
          filename: filename,
          content_type: 'text/csv',
        },
      ],
      ['caption', "Отчёт по участникам мероприятия: #{@event.name}"],
      ['chat_id', @user.telegram_id.to_s],
    ]
  end
end
