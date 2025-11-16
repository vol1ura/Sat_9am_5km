# frozen_string_literal: true

class ChangeAthletesAndBadges < ActiveRecord::Migration[7.0]
  def up
    change_column :athletes, :fiveverst_code, :bigint
    add_column :badges, :received_date, :date
  end

  def down
    change_column :athletes, :fiveverst_code, :integer
    remove_column :badges, :received_date
  end
end
