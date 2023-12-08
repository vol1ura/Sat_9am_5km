# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.boolean :active, default: true, null: false
      t.string :code_name
      t.string :town
      t.string :place
      t.text :description

      t.timestamps
    end
  end
end
