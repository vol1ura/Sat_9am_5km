# frozen_string_literal: true

class AddFlagsToResults < ActiveRecord::Migration[7.0]
  def change
    change_table :results, bulk: true do |t|
      t.boolean :personal_best, null: false, default: false
      t.boolean :first_run, null: false, default: false
    end
  end
end
