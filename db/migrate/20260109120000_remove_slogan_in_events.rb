# frozen_string_literal: true

class RemoveSloganInEvents < ActiveRecord::Migration[8.1]
  def up
    Event.update_all("name = regexp_replace(slogan, '\\s*\\([^)]+\\)\\s*$', '')")
    remove_column :events, :slogan, :string
  end

  def down
    add_column :events, :slogan, :string
    Event.update_all("slogan = name || ' (' || town || ')'")
  end
end
