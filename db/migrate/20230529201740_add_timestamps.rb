# frozen_string_literal: true

class AddTimestamps < ActiveRecord::Migration[7.0]
  def change
    current_time = Time.current
    %i[results trophies volunteers].each do |table|
      add_timestamps table, default: current_time
      change_column_default table, :created_at, from: current_time, to: nil
      change_column_default table, :updated_at, from: current_time, to: nil
    end
  end
end
