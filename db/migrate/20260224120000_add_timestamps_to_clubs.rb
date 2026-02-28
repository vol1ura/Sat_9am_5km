# frozen_string_literal: true

class AddTimestampsToClubs < ActiveRecord::Migration[8.1]
  def change
    add_timestamps :clubs, null: true

    Club.update_all(created_at: Time.current, updated_at: Time.current)

    change_table :clubs, bulk: true do |t|
      t.change_null :created_at, false
      t.change_null :updated_at, false
    end
  end
end
