# frozen_string_literal: true

class RemoveCounterCacheColumns < ActiveRecord::Migration[7.0]
  def change
    remove_column :athletes, :volunteering_count, :integer
    remove_column :activities, :results_count, :integer
  end
end
