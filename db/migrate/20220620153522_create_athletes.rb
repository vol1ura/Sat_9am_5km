# frozen_string_literal: true

class CreateAthletes < ActiveRecord::Migration[7.0]
  def change
    create_table :athletes do |t|
      t.string :name
      t.integer :parkrun_code, index: { unique: true }
      t.integer :fiveverst_code, index: { unique: true }
      t.boolean :male # rubocop:disable Rails/ThreeStateBooleanColumn
      t.references :user, foreign_key: true
      t.references :club, foreign_key: true

      t.timestamps
    end
  end
end
