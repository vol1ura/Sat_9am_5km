# frozen_string_literal: true

class CreateVolunteerApplications < ActiveRecord::Migration[8.1]
  def change
    create_table :volunteer_applications do |t|
      t.references :activity, null: false, foreign_key: true, index: false
      t.references :athlete, null: false, foreign_key: true
      t.integer :role, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :volunteer_applications, %i[activity_id athlete_id], unique: true
  end
end
