# frozen_string_literal: true

class VolunteersRoleCsvExportJob < ApplicationJob
  queue_as :low

  def perform(event_id, role, user_id, from_date = nil)
    @event = Event.find event_id
    @role = role
    @user = User.find user_id
    @from_date = Date.parse from_date if from_date
    return unless @user.telegram_id

    tempfile = generate_csv

    Telegram::Bot.call 'sendDocument', form_data: multipart_form_data(tempfile)
  rescue StandardError => e
    Rollbar.error e, user_id: @user.id, event_id: @event.id, role: @role
  ensure
    tempfile&.close
    tempfile&.unlink
  end

  private

  def generate_csv
    tempfile = Tempfile.new
    CSV.open(tempfile.path, 'w') do |csv|
      csv << %w[name id count]
      volunteers_dataset.each do |row|
        csv << [row.athlete_name, row.athlete_id, row.volunteering_count]
      end
    end
    tempfile.rewind
    tempfile
  end

  def volunteers_dataset
    scope = Volunteer.published.joins(:athlete, :activity).where(role: @role, activity: { event: @event })
    scope = scope.where(activity: { date: @from_date.. }) if @from_date
    scope
      .group('athletes.id')
      .order(volunteering_count: :desc)
      .select(
        'athletes.id AS athlete_id',
        'athletes.name AS athlete_name',
        'COUNT(volunteers.id) AS volunteering_count',
      )
  end

  def multipart_form_data(file)
    role_name = Volunteer.human_attribute_name "role.#{@role}"
    [
      [
        'document',
        file,
        {
          filename: "#{@event.code_name}_#{@role}_volunteers_#{Time.zone.now.to_i}.csv",
          content_type: 'text/csv',
        },
      ],
      ['caption', "Отчёт по волонтёрской позиции «#{role_name}» на мероприятии: #{@event.name}"],
      ['chat_id', @user.telegram_id.to_s],
    ]
  end
end
