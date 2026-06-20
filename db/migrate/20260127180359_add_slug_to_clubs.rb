# frozen_string_literal: true

class AddSlugToClubs < ActiveRecord::Migration[8.1]
  def change
    add_column :clubs, :slug, :string
    add_index :clubs, :slug, unique: true
    change_column_null :clubs, :slug, false
  end
end
