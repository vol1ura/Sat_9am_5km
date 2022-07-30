class ChangeAthletesAndBadges < ActiveRecord::Migration[7.0]
  def change
    change_column :athletes, :fiveverst_code, :bigint
    add_column :badges, :received_date, :date
  end
end
