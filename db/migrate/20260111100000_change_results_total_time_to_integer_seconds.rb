# frozen_string_literal: true

class ChangeResultsTotalTimeToIntegerSeconds < ActiveRecord::Migration[8.1]
  def up
    offset = ActiveSupport::TimeZone[Rails.application.config.time_zone].utc_offset

    change_column(
      :results,
      :total_time,
      :integer,
      using: "MOD(EXTRACT(EPOCH FROM total_time)::integer + #{offset}, 24 * 60 * 60)",
    )

    execute <<~SQL.squish
      UPDATE badges
      SET info = (info - 'min') || jsonb_build_object('sec', ((info->>'min')::integer * 60))
      WHERE kind = 30 AND info ? 'min'
    SQL

    execute <<~SQL.squish
      UPDATE audits
      SET audited_changes = jsonb_set(
        audited_changes,
        '{total_time}',
        CASE
          WHEN jsonb_typeof(audited_changes->'total_time') = 'string' THEN
            to_jsonb(
              MOD(
                EXTRACT(EPOCH FROM (audited_changes->>'total_time')::timestamptz)::integer + #{offset},
                24 * 60 * 60
              )
            )
          WHEN jsonb_typeof(audited_changes->'total_time') = 'array' THEN
            (
              SELECT jsonb_agg(
                CASE
                  WHEN jsonb_typeof(value) = 'string' THEN
                    to_jsonb(
                      MOD(
                        EXTRACT(EPOCH FROM (value #>> '{}')::timestamptz)::integer + #{offset},
                        24 * 60 * 60
                      )
                    )
                  ELSE value
                END
              )
              FROM jsonb_array_elements(audited_changes->'total_time') AS value
            )
          ELSE audited_changes->'total_time'
        END
      )
      WHERE auditable_type = 'Result' AND audited_changes ? 'total_time'
    SQL
  end

  def down
    tz = ActiveSupport::TimeZone[Rails.application.config.time_zone]
    offset = tz.utc_offset
    offset_str = tz.formatted_offset

    execute <<~SQL.squish
      UPDATE badges
      SET info = (info - 'sec') || jsonb_build_object('min', ((info->>'sec')::integer / 60))
      WHERE kind = 30 AND info ? 'sec'
    SQL

    change_column(
      :results,
      :total_time,
      :time,
      using: <<~SQL.squish,
        CASE
          WHEN total_time IS NULL THEN NULL
          ELSE (
            '00:00:00'::time +
            (MOD((total_time - #{offset})::integer, 24 * 60 * 60) || ' seconds')::interval
          )
        END
      SQL
    )

    execute <<~SQL.squish
      UPDATE audits
      SET audited_changes = jsonb_set(
        audited_changes,
        '{total_time}',
        CASE
          WHEN jsonb_typeof(audited_changes->'total_time') = 'number' THEN
            to_jsonb(
              to_char(
                timestamp '2000-01-01 00:00:00' +
                  (MOD((audited_changes->>'total_time')::integer, 24 * 60 * 60) || ' seconds')::interval,
                'YYYY-MM-DD"T"HH24:MI:SS.MS'
              ) || '#{offset_str}'
            )
          WHEN jsonb_typeof(audited_changes->'total_time') = 'array' THEN
            (
              SELECT jsonb_agg(
                CASE
                  WHEN jsonb_typeof(value) = 'number' THEN
                    to_jsonb(
                      to_char(
                        timestamp '2000-01-01 00:00:00' +
                          (MOD((value #>> '{}')::integer, 24 * 60 * 60) || ' seconds')::interval,
                        'YYYY-MM-DD"T"HH24:MI:SS.MS'
                      ) || '#{offset_str}'
                    )
                  ELSE value
                END
              )
              FROM jsonb_array_elements(audited_changes->'total_time') AS value
            )
          ELSE audited_changes->'total_time'
        END
      )
      WHERE auditable_type = 'Result' AND audited_changes ? 'total_time'
    SQL
  end
end
