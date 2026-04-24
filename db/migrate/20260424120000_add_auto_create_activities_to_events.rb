# frozen_string_literal: true

class AddAutoCreateActivitiesToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :auto_create_activities, :boolean, default: false, null: false
  end
end
