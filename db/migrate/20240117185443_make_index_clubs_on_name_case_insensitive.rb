# frozen_string_literal: true

class MakeIndexClubsOnNameCaseInsensitive < ActiveRecord::Migration[7.1]
  def change
    remove_index :clubs, :name, unique: true
    add_index :clubs, 'lower(name)', unique: true
  end
end
