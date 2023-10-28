# frozen_string_literal: true

class CreateVolunteeringPositions < ActiveRecord::Migration[7.0]
  def change
    create_table :volunteering_positions do |t|
      t.references :event, null: false, foreign_key: true
      t.integer :rank, null: false
      t.integer :role, null: false
      t.integer :number, null: false
    end

    add_index :volunteering_positions, %i[event_id role], unique: true
    remove_index :volunteering_positions, :event_id
  end
end
