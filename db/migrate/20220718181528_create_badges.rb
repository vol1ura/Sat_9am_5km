# frozen_string_literal: true

class CreateBadges < ActiveRecord::Migration[7.0]
  def change
    create_table :badges do |t|
      t.string :name
      t.text :conditions
      t.string :picture_link

      t.timestamps
    end
  end
end
