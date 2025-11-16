# frozen_string_literal: true

class EventAthletesCsvExportJob < ApplicationJob
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
      csv << %w[id name results_count volunteering_count]
      dataset_for.find_each do |athlete|
        csv << [athlete.id, athlete.name, athlete.results_count, athlete.volunteering_count]
      end
    end
    tempfile.rewind
    tempfile
  end

  def dataset_for
    results_subq = subquery_for(Result).select('athlete_id, COUNT(*) AS results_count')
    volunteering_subq = subquery_for(Volunteer).select('athlete_id, COUNT(*) AS volunteering_count')

    Athlete
      .joins("LEFT JOIN (#{results_subq.to_sql}) res ON res.athlete_id = athletes.id")
      .joins("LEFT JOIN (#{volunteering_subq.to_sql}) vol ON vol.athlete_id = athletes.id")
      .where('res.results_count IS NOT NULL OR vol.volunteering_count IS NOT NULL')
      .select(
        'athletes.id,athletes.name,' \
        'COALESCE(res.results_count, 0) AS results_count,COALESCE(vol.volunteering_count, 0) AS volunteering_count',
      )
  end

  def subquery_for(model)
    model.published.where(activity: { event: @event }).where.not(athlete_id: nil).group(:athlete_id)
  end

  def multipart_form_data(file)
    [
      [
        'document',
        file,
        {
          filename: "#{@event.code_name}_participants_#{Time.zone.now.to_i}.csv",
          content_type: 'text/csv',
        },
      ],
      ['caption', "Отчёт по участникам мероприятия: #{@event.name}"],
      ['chat_id', @user.telegram_id.to_s],
    ]
  end
end
