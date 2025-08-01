# frozen_string_literal: true

class AddPersonalBestsToAthletes < ActiveRecord::Migration[8.0]
  def change
    add_column :athletes, :personal_bests, :jsonb, default: {}, null: false
  end
end
