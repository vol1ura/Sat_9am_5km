# frozen_string_literal: true

class AddNameToEvent < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :name, :string
  end
end
