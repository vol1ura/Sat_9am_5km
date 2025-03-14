class AddGoingToEventToAthletes < ActiveRecord::Migration[8.0]
  def change
    add_reference :athletes, :going_to_event, null: true, foreign_key: { to_table: :events }
  end
end
