# frozen_string_literal: true

class AddNumericalityCheckConstraints < ActiveRecord::Migration[8.1]
  def change
    add_check_constraint :volunteering_positions, 'rank >= 1', name: 'chk_volunteering_positions_rank'
    add_check_constraint :volunteering_positions, 'number >= 1', name: 'chk_volunteering_positions_number'

    add_check_constraint :results, 'position >= 1', name: 'chk_results_position'

    add_check_constraint :athletes, 'parkrun_code < 770000000', name: 'chk_athletes_parkrun_code'
    add_check_constraint :athletes, 'fiveverst_code > 790000000', name: 'chk_athletes_fiveverst_code'
    add_check_constraint :athletes, 'runpark_code > 7000000000', name: 'chk_athletes_runpark_code'
    add_check_constraint :athletes, 'parkzhrun_code > 690000000', name: 'chk_athletes_parkzhrun_code'
  end
end
