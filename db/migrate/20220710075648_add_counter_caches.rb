# frozen_string_literal: true

class AddCounterCaches < ActiveRecord::Migration[7.0]
  def up
    add_column :athletes, :volunteering_count, :integer
    add_column :activities, :results_count, :integer

    Athlete.all.find_each do |athlete|
      Athlete.reset_counters(athlete.id, :volunteering)
    end
    Activity.all.find_each do |activity|
      Activity.reset_counters(activity.id, :results)
    end
  end

  def down
    remove_column :athletes, :volunteering_count
    remove_column :activities, :results_count
  end
end
