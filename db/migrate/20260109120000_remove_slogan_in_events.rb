# frozen_string_literal: true

class RemoveSloganInEvents < ActiveRecord::Migration[8.1]
  def up
    remove_column :events, :slogan, :string
  end

  def down
    add_column :events, :slogan, :string
  end
end
