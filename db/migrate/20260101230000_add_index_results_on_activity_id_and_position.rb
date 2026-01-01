# frozen_string_literal: true

class AddIndexResultsOnActivityIdAndPosition < ActiveRecord::Migration[8.0]
  def change
    add_index :results, %i[activity_id position]
    remove_index :results, :activity_id
  end
end
