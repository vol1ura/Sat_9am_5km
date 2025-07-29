# frozen_string_literal: true

class AddLiveResultsToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :live_results, :jsonb
  end
end
