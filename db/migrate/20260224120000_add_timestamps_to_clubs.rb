# frozen_string_literal: true

class AddTimestampsToClubs < ActiveRecord::Migration[8.1]
  def change
    add_timestamps :clubs, null: false
  end
end
