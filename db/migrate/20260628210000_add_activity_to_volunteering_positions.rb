# frozen_string_literal: true

class AddActivityToVolunteeringPositions < ActiveRecord::Migration[8.1]
  def change
    add_reference :volunteering_positions, :activity, foreign_key: true, null: true

    remove_index :volunteering_positions, %i[event_id role]
    add_index :volunteering_positions, %i[event_id role],
              unique: true, where: 'activity_id IS NULL', name: 'index_volunteering_positions_on_default_event_role'
    add_index :volunteering_positions, %i[event_id activity_id role],
              unique: true, name: 'index_volunteering_positions_on_event_activity_role'
  end
end
