# frozen_string_literal: true

class CreatePermissions < ActiveRecord::Migration[7.0]
  def change
    create_table :permissions do |t|
      t.bigint :event_id
      t.bigint :subject_id
      t.string :subject_class
      t.string :action

      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
