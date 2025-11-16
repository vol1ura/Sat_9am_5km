# frozen_string_literal: true

class CreateTrophies < ActiveRecord::Migration[7.0]
  def change
    create_table :trophies do |t|
      t.references :badge, null: false, foreign_key: true
      t.references :athlete, null: false, foreign_key: true

      t.date :date
    end

    add_index :trophies, %i[badge_id athlete_id], unique: true
  end
end
