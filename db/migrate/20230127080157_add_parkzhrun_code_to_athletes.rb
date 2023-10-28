# frozen_string_literal: true

class AddParkzhrunCodeToAthletes < ActiveRecord::Migration[7.0]
  def change
    add_column :athletes, :parkzhrun_code, :bigint
    add_index :athletes, :parkzhrun_code, unique: true
  end
end
