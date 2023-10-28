# frozen_string_literal: true

class AddAthleteActivityUniqueIndexOnVolunteers < ActiveRecord::Migration[7.0]
  def change
    add_index :volunteers, %i[activity_id athlete_id], unique: true
    remove_index :volunteers, :activity_id
  end
end
