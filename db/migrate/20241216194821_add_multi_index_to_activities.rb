# frozen_string_literal: true

class AddMultiIndexToActivities < ActiveRecord::Migration[8.0]
  def change
    remove_index :activities, :event_id
    add_index :activities, %i[event_id date]
  end
end
