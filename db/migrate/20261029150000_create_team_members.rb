# frozen_string_literal: true

class CreateTeamMembers < ActiveRecord::Migration[8.1]
  def change
    create_table :team_members do |t|
      t.references :athlete, null: false, foreign_key: true, index: { unique: true }
      t.jsonb :role_translations, null: false, default: {}
      t.integer :rank, null: false, default: 1
      t.timestamps
      t.check_constraint 'rank >= 1', name: 'chk_team_members_rank'
    end
  end
end
