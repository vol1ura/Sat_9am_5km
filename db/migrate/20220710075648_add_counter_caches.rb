# frozen_string_literal: true

class AddCounterCaches < ActiveRecord::Migration[7.0]
  def change
    add_column :athletes, :volunteering_count, :integer
    add_column :activities, :results_count, :integer
  end
end
