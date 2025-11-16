# frozen_string_literal: true

class AddTimezoneToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :timezone, :string, null: false, default: 'Europe/Moscow'
  end
end
