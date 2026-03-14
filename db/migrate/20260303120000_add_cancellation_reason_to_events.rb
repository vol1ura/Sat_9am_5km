# frozen_string_literal: true

class AddCancellationReasonToEvents < ActiveRecord::Migration[8.1]
  def change
    change_table :events, bulk: true do |t|
      t.boolean :active, default: false, null: false
      t.string :cancellation_reason
    end
  end
end
