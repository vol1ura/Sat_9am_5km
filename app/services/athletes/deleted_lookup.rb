# frozen_string_literal: true

module Athletes
  class DeletedLookup < ApplicationService
    Result = Data.define(:status, :athlete, :snapshot, :merged_at, :merged_by)

    def initialize(athlete_id)
      @athlete_id = athlete_id
    end

    def call
      return result(:not_found) unless @athlete_id.positive?

      existing_athlete = Athlete.find_by(id: @athlete_id)
      return result(:exists, athlete: existing_athlete) if existing_athlete
      return result(:not_found) unless athlete_destroy_audit

      current_athlete =
        find_athlete_updated_in_request || find_athlete_from_merged_user || find_surviving_from_participation
      result(
        current_athlete ? :reunited : :destroyed,
        athlete: current_athlete,
        snapshot: athlete_destroy_audit.audited_changes,
        merged_at: athlete_destroy_audit.created_at,
        merged_by: athlete_destroy_audit.user,
      )
    end

    private

    def result(status, athlete: nil, snapshot: nil, merged_at: nil, merged_by: nil)
      Result.new(status:, athlete:, snapshot:, merged_at:, merged_by:)
    end

    def athlete_destroy_audit
      return @athlete_destroy_audit if @athlete_destroy_audit

      @athlete_destroy_audit =
        Audited::Audit.find_by(auditable_type: 'Athlete', auditable_id: @athlete_id, action: 'destroy')
    end

    def find_athlete_updated_in_request
      ids = audits_in_request(auditable_type: 'Athlete').where.not(auditable_id: @athlete_id).distinct.pluck(:auditable_id)
      single_living_athlete(Athlete.where(id: ids))
    end

    def find_athlete_from_merged_user
      user_ids = audits_in_request(auditable_type: 'User').distinct.pluck(:auditable_id)
      single_living_athlete(Athlete.where(user_id: user_ids))
    end

    def single_living_athlete(athletes)
      athletes.take if athletes.one?
    end

    def audits_in_request(auditable_type:)
      uuid = athlete_destroy_audit.request_uuid
      return Audited::Audit.none if uuid.blank?

      Audited::Audit.where(auditable_type: auditable_type, action: 'update').where(request_uuid: uuid)
    end

    def find_surviving_from_participation
      record_ids = participation_audits.group_by(&:auditable_type).transform_values { |rows| rows.map(&:auditable_id) }
      current_ids = record_ids.flat_map do |type, ids|
        type.constantize.where(id: ids).where.not(athlete_id: nil).distinct.pluck(:athlete_id)
      end
      current_ids.delete(@athlete_id)

      single_living_athlete(Athlete.where(id: current_ids))
    end

    def participation_audits
      Audited::Audit
        .where(auditable_type: %w[Result Volunteer])
        .where("audited_changes->'athlete_id' @> ?::jsonb", @athlete_id.to_s)
    end
  end
end
