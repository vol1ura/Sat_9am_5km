# frozen_string_literal: true

class AddPlaceDescriptionColumnInEvents < ActiveRecord::Migration[8.1]
  def up
    change_table :events, bulk: true do |t|
      t.rename :place, :place_description
      t.change :place_description, :text
      t.column :place, :string
    end

    Event.update_all('place = name')

    change_table :events, bulk: true do |t|
      t.change :place, :string, null: false
      t.change :description, :text, null: false
    end
  end

  def down
    change_table :events, bulk: true do |t|
      t.change :place, :string
      t.change :description, :text, null: true
      t.remove :place_description
    end
  end
end
