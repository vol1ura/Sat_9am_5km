# frozen_string_literal: true

class AddGoingToEventToAthletes < ActiveRecord::Migration[8.0]
  def change
    add_reference :athletes, :going_to_event, null: true, foreign_key: { to_table: :events, on_delete: :nullify }
  end
end
