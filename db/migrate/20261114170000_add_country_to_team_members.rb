# frozen_string_literal: true

class AddCountryToTeamMembers < ActiveRecord::Migration[8.1]
  def up
    add_reference :team_members, :country, foreign_key: true

    execute <<~SQL.squish
      UPDATE team_members
      SET country_id = (SELECT id FROM countries WHERE code = 'ru' LIMIT 1)
      WHERE country_id IS NULL
    SQL

    change_column_null :team_members, :country_id, false
  end

  def down
    remove_reference :team_members, :country, foreign_key: true
  end
end
