# frozen_string_literal: true

class AddRunparkCodeToAthletes < ActiveRecord::Migration[7.0]
  def change
    add_column :athletes, :runpark_code, :bigint
    add_index :athletes, :runpark_code, unique: true
  end
end
