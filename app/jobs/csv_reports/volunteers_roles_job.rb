# frozen_string_literal: true

module CsvReports
  class VolunteersRolesJob < BaseJob
    HEADERS = %w[role name id count].freeze

    def perform(event_id, user_id, from_date = nil, till_date = nil)
      @event = Event.find event_id
      @from_date = Date.parse from_date if from_date
      @till_date = Date.parse till_date if till_date
      user = User.find user_id
      tempfile = generate_csv(data) { |arr| arr }

      notify(
        user,
        file: tempfile,
        filename: "#{@event.code_name}_volunteers_#{Time.zone.now.to_i}.csv",
        caption: "Отчёт по волонтёрским позициям на мероприятии: #{@event.name}",
      )
    rescue StandardError => e
      Rollbar.error e, user_id: user.id, event_id: @event.id
    ensure
      tempfile&.close
      tempfile&.unlink
    end

    private

    def data
      Volunteer.roles.each_key.with_object([]) do |role, results|
        human_volunteer_role = I18n.t("activerecord.attributes.volunteer.roles.#{role}")
        scope = Volunteer.published.joins(:athlete, :activity).where(role: role, activity: { event: @event })
        scope = scope.where(activity: { date: date_range }) if date_range
        rows = scope
          .group('athletes.id')
          .order(volunteering_count: :desc)
          .select(
            'athletes.id AS athlete_id',
            'athletes.name AS athlete_name',
            'COUNT(volunteers.id) AS volunteering_count',
          )
        rows.each { |row| results << [human_volunteer_role, row.athlete_name, row.athlete_id, row.volunteering_count] }
      end
    end
  end
end
