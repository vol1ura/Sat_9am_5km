# frozen_string_literal: true

class AddStatsToAthletes < ActiveRecord::Migration[7.1]
  def change
    add_column :athletes, :stats, :jsonb, default: {}, null: false
    add_index :athletes, :stats, using: :gin
  end
end
