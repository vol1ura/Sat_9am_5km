# frozen_string_literal: true

class FixDatabaseConsistency < ActiveRecord::Migration[7.0]
  def up
    change_table :badges, bulk: true do |t|
      t.change :name, :string, null: false
      t.change :picture_link, :string, null: false
    end
    change_table :contacts, bulk: true do |t|
      t.change :contact_type, :integer, null: false
      t.change :link, :string, null: false
    end
    change_table :events, bulk: true do |t|
      t.change :name, :string, null: false
      t.change :code_name, :string, null: false
      t.change :town, :string, null: false
      t.change :place, :string, null: false
    end
    change_column :activities, :event_id, :bigint, null: false
    change_column :clubs, :name, :string, null: false
    change_column :volunteers, :role, :integer, null: false
    remove_index :trophies, :badge_id
    remove_index :contacts, :event_id
    remove_index :athletes, :user_id
    add_index :athletes, :user_id, unique: true
  end

  def down
    change_table :badges, bulk: true do |t|
      t.change :name, :string, null: true
      t.change :picture_link, :string, null: true
    end
    change_table :contacts, bulk: true do |t|
      t.change :contact_type, :integer, null: true
      t.change :link, :string, null: true
    end
    change_table :events, bulk: true do |t|
      t.change :name, :string, null: true
      t.change :code_name, :string, null: true
      t.change :town, :string, null: true
      t.change :place, :string, null: true
    end
    change_column :activities, :event_id, :bigint, null: true
    change_column :clubs, :name, :string, null: true
    change_column :volunteers, :role, :integer, null: true
    add_index :trophies, :badge_id
    add_index :contacts, :event_id
    remove_index :athletes, :user_id, unique: true
    add_index :athletes, :user_id
  end
end
