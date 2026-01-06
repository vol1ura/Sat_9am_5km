# frozen_string_literal: true

module Athletes
  class DuplicatesService < ApplicationService
    option :name, reader: :private, default: -> {}

    def call
      Athlete
        .with(sorted_names: sorted_names_query, name_stats: name_stats_query)
        .from(joined_names_query)
        .where('name_cnt > 1')
        .where('user_cnt < name_cnt')
        .where('event_cnt < name_cnt')
        .where('parkrun_cnt < name_cnt')
        .where('fiveverst_cnt < name_cnt')
        .where('runpark_cnt < name_cnt')
        .select(:id)
    end

    private

    def sorted_names_query
      ds =
        Athlete
          .select(
            :id,
            :user_id,
            :event_id,
            :parkrun_code,
            :fiveverst_code,
            :runpark_code,
            Arel.sql("string_agg(words, ' ' ORDER BY words) AS normalized_name"),
          )
          .from(Arel.sql("athletes, unnest(string_to_array(LOWER(name), ' ')) AS words"))
          .group(:id)

      return ds unless name

      ds.having("string_agg(words, ' ' ORDER BY words) = ?", name.downcase.split.sort.join(' '))
    end

    def name_stats_query
      Arel.sql(
        <<~SQL.squish,
          SELECT
            normalized_name,
            COUNT(*) AS name_cnt,
            COUNT(user_id) AS user_cnt,
            COUNT(DISTINCT event_id) AS event_cnt,
            COUNT(parkrun_code) AS parkrun_cnt,
            COUNT(fiveverst_code) AS fiveverst_cnt,
            COUNT(runpark_code) AS runpark_cnt
          FROM sorted_names
          GROUP BY normalized_name
        SQL
      )
    end

    def joined_names_query
      Arel.sql(
        <<~SQL.squish,
          (
            SELECT
              sorted_names.id,
              name_stats.name_cnt,
              name_stats.user_cnt,
              name_stats.event_cnt,
              name_stats.parkrun_cnt,
              name_stats.fiveverst_cnt,
              name_stats.runpark_cnt
            FROM sorted_names
            INNER JOIN name_stats ON name_stats.normalized_name = sorted_names.normalized_name
          ) AS grouped_names
        SQL
      )
    end
  end
end
