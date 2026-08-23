# frozen_string_literal: true

class AddColumnsToBadges < ActiveRecord::Migration[7.0]
  def change
    change_table :badges, bulk: true do |t|
      t.column :kind, :integer, default: 0, null: false
      t.column :info, :jsonb, default: '{}', null: false
      t.index :info, using: :gin
    end

    change_table :trophies, bulk: true do |t|
      t.column :info, :jsonb, default: '{}', null: false
      t.index :info, using: :gin
    end
  end
end
