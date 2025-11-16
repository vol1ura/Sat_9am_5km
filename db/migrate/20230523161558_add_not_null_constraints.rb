# frozen_string_literal: true

class AddNotNullConstraints < ActiveRecord::Migration[7.0]
  def up
    change_column :events, :active, :boolean, default: true, null: false
    change_column :activities, :published, :boolean, default: false, null: false
  end

  def down
    change_column :events, :active, :boolean, default: true
    change_column :activities, :published, :boolean, default: false
  end
end
