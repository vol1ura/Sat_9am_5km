# frozen_string_literal: true

module Cup
  class AthletePayload
    MAIN_ROLES = Volunteer.roles.keys - %w[other]

    def initialize(athletes)
      @athletes = athletes
    end

    def as_json
      @athletes.map { |athlete| row(athlete) }
    end

    private

    def row(athlete)
      {
        id: athlete.id,
        code: athlete.code,
        name: athlete.name,
        gender: athlete.gender,
        home_event_code: athlete.event&.code_name,
        home_event_name: athlete.event&.name,
        club_name: athlete.club&.name,
        runs_count: runs_count(athlete),
        volunteering_count: volunteering_count(athlete),
      }
    end

    def runs_count(athlete)
      athlete.stats.to_h.dig('results', 'count').to_i
    end

    def volunteering_count(athlete)
      return athlete.stats.to_h.dig('volunteers', 'count').to_i unless runs_count(athlete).zero?

      main_role_counts[athlete.id].to_i
    end

    def main_role_counts
      @main_role_counts ||= counts_for(zero_run_ids)
    end

    def counts_for(ids)
      return {} if ids.empty?

      Volunteer.published.where(athlete_id: ids, role: MAIN_ROLES).group(:athlete_id).count
    end

    def zero_run_ids
      @athletes.select { |athlete| runs_count(athlete).zero? }.map(&:id)
    end
  end
end
