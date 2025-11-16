class EventDetailedResultsCsvExportJob < ApplicationJob
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
    volunteers_map = Volunteer.published.joins(:activity).where(activities: { event_id: @event.id }).pluck('volunteers.activity_id', 'volunteers.athlete_id', 'volunteers.role').each_with_object({}) do |(aid, ath_id, role), h|
      h[[aid, ath_id]] = Volunteer.roles.key(role)
    end

    CSV.open(tempfile.path, 'w') do |csv|
      csv << %w[activity_date activity_id result_id athlete_id athlete_name parkrun_code gender total_time position club volunteer_role]
      dataset.find_each do |r|
        athlete = r.athlete
        club_name = athlete&.club&.name
        volunteer_role = volunteers_map[[r.activity_id, athlete&.id]]
        csv << [r.activity.date.strftime('%d.%m.%Y'), r.activity_id, r.id, athlete&.id, athlete&.name, athlete&.parkrun_code, athlete&.gender, r.total_time&.strftime('%H:%M:%S'), r.position, club_name, volunteer_role]
      end
    end
    tempfile.rewind
    tempfile
  end

  def dataset
    Result.published.joins(:activity).where(activities: { event_id: @event.id }).includes(athlete: :club, activity: {}).order('activities.date ASC, results.position ASC')
  end

  def multipart_form_data(file)
    [
      [
        'document',
        file,
        {
          filename: "#{@event.code_name}_detailed_results_#{Time.zone.now.to_i}.csv",
          content_type: 'text/csv'
        }
      ],
      ['caption', "Детализированный отчёт по результатам мероприятия: #{@event.name}"],
      ['chat_id', @user.telegram_id.to_s]
    ]
  end
end
