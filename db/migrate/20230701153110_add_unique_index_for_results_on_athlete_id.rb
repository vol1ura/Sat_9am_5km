# frozen_string_literal: true

class AddUniqueIndexForResultsOnAthleteId < ActiveRecord::Migration[7.0]
  def change
    remove_index :results, :athlete_id
    add_index :results, %i[athlete_id activity_id], unique: true
  end
end
