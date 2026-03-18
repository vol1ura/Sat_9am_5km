# frozen_string_literal: true

class AddCancellationReasonToEvents < ActiveRecord::Migration[8.1]
  def change
    change_table :events, bulk: true do |t|
      t.change_default :active, from: true, to: false
      t.string :cancellation_reason
    end
  end
end
