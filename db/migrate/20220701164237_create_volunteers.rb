# frozen_string_literal: true

class CreateVolunteers < ActiveRecord::Migration[7.0]
  def change
    create_table :volunteers do |t|
      t.integer :role
      t.references :activity, null: false, foreign_key: true
      t.references :athlete, null: false, foreign_key: true
    end

    remove_column :results, :role, :integer
  end
end
