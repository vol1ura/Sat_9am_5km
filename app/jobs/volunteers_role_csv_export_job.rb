# frozen_string_literal: true

class VolunteersRoleCsvExportJob < ApplicationJob
  queue_as :low

  def perform(event_id, role, user_id, from_date = nil)
    @event = Event.find event_id
    @role = role
    @user = User.find user_id
    @from_date = Date.parse from_date if from_date
    return unless @user.telegram_id

    exporter = CsvExport::VolunteersRole.new(event: @event, role: @role, from_date: @from_date)
    
    tempfile = Tempfile.new(['export', '.csv'])
    tempfile.write(exporter.generate)
    tempfile.rewind

    Telegram::Bot.call 'sendDocument', form_data: multipart_form_data(tempfile, exporter.filename)
  rescue StandardError => e
    Rollbar.error e, user_id: @user.id, event_id: @event.id, role: @role
  ensure
    tempfile&.close
    tempfile&.unlink
  end

  private

  def multipart_form_data(file, filename)
    if @role
      role_name = Volunteer.human_attribute_name "role.#{@role}"
      caption = "Отчёт по волонтёрской позиции «#{role_name}» на мероприятии: #{@event.name}"
    else
      caption = "Отчёт по всем волонтёрским позициям на мероприятии: #{@event.name}"
    end
    
    [
      [
        'document',
        file,
        {
          filename: filename,
          content_type: 'text/csv',
        },
      ],
      ['caption', caption],
      ['chat_id', @user.telegram_id.to_s],
    ]
  end
end
