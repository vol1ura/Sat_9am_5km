# frozen_string_literal: true

class FixUsersConsistency < ActiveRecord::Migration[7.0]
  def up
    change_table :users, bulk: true do |t|
      t.change :first_name, :string, null: false
      t.change :last_name, :string, null: false
    end
  end

  def down
    change_table :users, bulk: true do |t|
      t.change :first_name, :string, null: true
      t.change :last_name, :string, null: true
    end
  end
end
