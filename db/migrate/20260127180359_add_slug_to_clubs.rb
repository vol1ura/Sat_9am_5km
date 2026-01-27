# frozen_string_literal: true

class AddSlugToClubs < ActiveRecord::Migration[8.1]
  def up
    add_column :clubs, :slug, :string
    Club.update_all('slug = id')
    add_index :clubs, :slug, unique: true
    change_column_null :clubs, :slug, false
  end

  def down
    remove_column :clubs, :slug
  end
end
