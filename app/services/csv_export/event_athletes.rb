# frozen_string_literal: true

module CsvExport
  class EventAthletes
    def initialize(event:, from_date: nil)
      @event = event
      @from_date = from_date
    end

    def generate
      CSV.generate do |csv|
        csv << %w[id name results_count volunteering_count]
        dataset.find_each do |athlete|
          csv << [athlete.id, athlete.name, athlete.results_count, athlete.volunteering_count]
        end
      end
    end

    def filename
      "#{@event.code_name}_participants_#{Time.zone.now.to_i}.csv"
    end

    private

    def dataset
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
      scope = model.published.where(activity: { event: @event }).where.not(athlete_id: nil)
      scope = scope.where(activity: { date: @from_date.. }) if @from_date
      scope.group(:athlete_id)
    end
  end
end
