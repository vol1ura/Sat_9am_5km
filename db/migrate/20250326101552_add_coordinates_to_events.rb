# frozen_string_literal: true

class AddCoordinatesToEvents < ActiveRecord::Migration[8.0]
  def change
    change_table :events, bulk: true do |t|
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
    end
  end
end
