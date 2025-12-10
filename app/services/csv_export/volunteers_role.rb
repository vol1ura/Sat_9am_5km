# frozen_string_literal: true

module CsvExport
  class VolunteersRole
    def initialize(event:, role: nil, from_date: nil)
      @event = event
      @role = role
      @from_date = from_date
    end

    def generate
      CSV.generate do |csv|
        if @role
          csv << %w[name id count]
          dataset.each do |row|
            csv << [row.athlete_name, row.athlete_id, row.volunteering_count]
          end
        else
          csv << %w[name id role count]
          dataset.each do |row|
            csv << [row.athlete_name, row.athlete_id, row.volunteer_role, row.volunteering_count]
          end
        end
      end
    end

    def filename
      if @role
        "#{@event.code_name}_#{@role}_volunteers_#{Time.zone.now.to_i}.csv"
      else
        "#{@event.code_name}_all_volunteers_#{Time.zone.now.to_i}.csv"
      end
    end

    private

    def dataset
      scope = Volunteer.published.joins(:athlete, :activity).where(activity: { event: @event })
      scope = scope.where(role: @role) if @role
      scope = scope.where(activity: { date: @from_date.. }) if @from_date

      if @role
        scope
          .group('athletes.id')
          .order(volunteering_count: :desc)
          .select(
            'athletes.id AS athlete_id',
            'athletes.name AS athlete_name',
            'COUNT(volunteers.id) AS volunteering_count',
          )
      else
        scope
          .group('athletes.id', 'volunteers.role')
          .order('athletes.name', 'volunteers.role')
          .select(
            'athletes.id AS athlete_id',
            'athletes.name AS athlete_name',
            'volunteers.role AS volunteer_role',
            'COUNT(volunteers.id) AS volunteering_count',
          )
      end
    end
  end
end
