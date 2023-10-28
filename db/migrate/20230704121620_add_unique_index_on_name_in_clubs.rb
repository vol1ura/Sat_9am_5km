# frozen_string_literal: true

class AddUniqueIndexOnNameInClubs < ActiveRecord::Migration[7.0]
  def change
    add_index :clubs, :name, unique: true
  end
end
