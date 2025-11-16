# frozen_string_literal: true

class AddNoteToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :note, :string
  end
end
