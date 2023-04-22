class AddHomeEventToAthlete < ActiveRecord::Migration[7.0]
  def change
    add_reference :athletes, :event
    add_foreign_key :athletes, :events, on_delete: :nullify
  end
end
