# frozen_string_literal: true

class AddCountryToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :country, foreign_key: { on_delete: :nullify }

    reversible do |dir|
      dir.up { backfill_country_id }
    end
  end

  private

  def backfill_country_id
    execute <<~SQL.squish
      UPDATE users
      SET country_id = COALESCE(
        (
          SELECT events.country_id
          FROM athletes
          INNER JOIN events ON events.id = athletes.event_id
          WHERE athletes.user_id = users.id
        ),
        (
          SELECT clubs.country_id
          FROM athletes
          INNER JOIN clubs ON clubs.id = athletes.club_id
          WHERE athletes.user_id = users.id
        ),
        (
          SELECT events.country_id
          FROM athletes
          INNER JOIN results ON results.athlete_id = athletes.id
          INNER JOIN activities ON activities.id = results.activity_id
          INNER JOIN events ON events.id = activities.event_id
          WHERE athletes.user_id = users.id
          ORDER BY activities.date ASC, activities.id ASC
          LIMIT 1
        ),
        (
          SELECT events.country_id
          FROM athletes
          INNER JOIN volunteers ON volunteers.athlete_id = athletes.id
          INNER JOIN activities ON activities.id = volunteers.activity_id
          INNER JOIN events ON events.id = activities.event_id
          WHERE athletes.user_id = users.id
          ORDER BY activities.date ASC, activities.id ASC
          LIMIT 1
        ),
        (SELECT id FROM countries WHERE code = 'ru' LIMIT 1)
      )
      WHERE country_id IS NULL
    SQL
  end
end
