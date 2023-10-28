# frozen_string_literal: true

class FixDatabaseConsistency < ActiveRecord::Migration[7.0]
  def up
    change_column :activities, :event_id, :bigint, null: false
    change_column :badges, :name, :string, null: false
    change_column :badges, :picture_link, :string, null: false
    change_column :clubs, :name, :string, null: false
    change_column :contacts, :contact_type, :integer, null: false
    change_column :contacts, :link, :string, null: false
    change_column :events, :name, :string, null: false
    change_column :events, :code_name, :string, null: false
    change_column :events, :town, :string, null: false
    change_column :events, :place, :string, null: false
    change_column :volunteers, :role, :integer, null: false
    remove_index :trophies, :badge_id
    remove_index :contacts, :event_id
    remove_index :athletes, :user_id
    add_index :athletes, :user_id, unique: true
  end

  def down
    change_column :activities, :event_id, :bigint, null: true
    change_column :badges, :name, :string, null: true
    change_column :badges, :picture_link, :string, null: true
    change_column :clubs, :name, :string, null: true
    change_column :contacts, :contact_type, :integer, null: true
    change_column :contacts, :link, :string, null: true
    change_column :events, :name, :string, null: true
    change_column :events, :code_name, :string, null: true
    change_column :events, :town, :string, null: true
    change_column :events, :place, :string, null: true
    change_column :volunteers, :role, :integer, null: true
    add_index :trophies, :badge_id
    add_index :contacts, :event_id
    remove_index :athletes, :user_id, unique: true
    add_index :athletes, :user_id
  end
end
