# frozen_string_literal: true

module Athletes
  class DuplicatesFinder < ApplicationService
    def initialize(name: nil)
      @name = name
    end

    def call
      Athlete
        .with(sorted_names: sorted_names_query)
        .from(grouped_names_query)
        .where('name_cnt > 1')
        .where('user_cnt < name_cnt')
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
            :parkrun_code,
            :fiveverst_code,
            :runpark_code,
            Arel.sql("string_agg(words, ' ' ORDER BY words) AS normalized_name"),
          )
          .from(Arel.sql("athletes, unnest(string_to_array(LOWER(name), ' ')) AS words"))
          .group(:id, :user_id, :parkrun_code, :fiveverst_code, :runpark_code)

      ds = ds.having("string_agg(words, ' ' ORDER BY words) = ?", @name.downcase.split.sort.join(' ')) if @name
      ds
    end

    def grouped_names_query
      grouped_names = Arel::Table.new(:sorted_names)
      grouped_names
        .project(
          grouped_names[:id],
          grouped_names[:user_id],
          grouped_names[:parkrun_code],
          grouped_names[:fiveverst_code],
          grouped_names[:runpark_code],
          grouped_names[:normalized_name],
          Arel.sql('COUNT(*) OVER (PARTITION BY normalized_name) AS name_cnt'),
          Arel.sql('COUNT(user_id) OVER (PARTITION BY normalized_name) AS user_cnt'),
          Arel.sql('COUNT(parkrun_code) OVER (PARTITION BY normalized_name) AS parkrun_cnt'),
          Arel.sql('COUNT(fiveverst_code) OVER (PARTITION BY normalized_name) AS fiveverst_cnt'),
          Arel.sql('COUNT(runpark_code) OVER (PARTITION BY normalized_name) AS runpark_cnt'),
        ).as('grouped_names')
    end
  end
end
