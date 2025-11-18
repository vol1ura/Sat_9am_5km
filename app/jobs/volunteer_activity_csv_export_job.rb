class VolunteerActivityCsvExportJob < ApplicationJob
  queue_as :low

  def perform(event_id, user_id)
    @event = Event.find(event_id)
    @user = User.find(user_id)
    return unless @user.telegram_id

    tempfile = generate_csv

    Telegram::Bot.call('sendDocument', form_data: multipart_form_data(tempfile))
  rescue StandardError => e
    Rollbar.error e, user_id: @user.id, event_id: @event.id
  ensure
    tempfile&.close
    tempfile&.unlink
  end

  private

  def generate_csv
    tempfile = Tempfile.new
    CSV.open(tempfile.path, 'w') do |csv|
      csv << %w[activity_date activity_id athlete_id athlete_name role comment club]
      dataset.find_each do |v|
        athlete = v.athlete
        csv << [v.activity.date.strftime('%d.%m.%Y'), v.activity_id, athlete&.id, athlete&.name, v.role, v.comment, athlete&.club&.name]
      end
    end
    tempfile.rewind
    tempfile
  end

  def dataset
    Volunteer.published.joins(:activity).where(activities: { event_id: @event.id }).includes(:athlete, activity: {}).order('activities.date DESC')
  end

  def multipart_form_data(file)
    [
      [
        'document',
        file,
        {
          filename: "#{@event.code_name}_volunteers_#{Time.zone.now.to_i}.csv",
          content_type: 'text/csv'
        }
      ],
      ['caption', "Отчёт по волонтёрствам мероприятия: #{@event.name}"],
      ['chat_id', @user.telegram_id.to_s]
    ]
  end
end
