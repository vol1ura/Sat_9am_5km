# frozen_string_literal: true

class VolunteersRolesCsvExportJob < ApplicationJob
  queue_as :low

  def perform(event_id, user_id, from_date = nil)
    @event = Event.find event_id
    @user = User.find user_id
    @from_date = Date.parse from_date if from_date
    return unless @user.telegram_id

    tempfile = generate_csv

    Telegram::Notification::File.call(
      @user,
      file: tempfile,
      filename: "#{@event.code_name}_volunteers_#{Time.zone.now.to_i}.csv",
      caption: "Отчёт по волонтёрским позициям на мероприятии: #{@event.name}",
    )
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
      csv << %w[role name id count]
      Volunteer.roles.each_key do |role|
        dataset_for(role).each do |row|
          human_volunteer_role = I18n.t("activerecord.attributes.volunteer.roles.#{role}")
          csv << [human_volunteer_role, row.athlete_name, row.athlete_id, row.volunteering_count]
        end
      end
    end
    tempfile.rewind
    tempfile
  end

  def dataset_for(role)
    scope = Volunteer.published.joins(:athlete, :activity).where(role: role, activity: { event: @event })
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
end
