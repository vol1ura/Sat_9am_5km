class AddRunparkCodeToAthletes < ActiveRecord::Migration[7.0]
  def up
    add_column :athletes, :runpark_code, :bigint
    add_index :athletes, :runpark_code, unique: true

    Athlete.where('fiveverst_code > ?', Athlete::RUN_PARK_BORDER).find_each do |athlete|
      athlete.update!(fiveverst_code: nil, runpark_code: athlete.fiveverst_code)
    end
  end

  def down
    Athlete.where.not(runpark_code: nil).find_each do |athlete|
      athlete.update!(fiveverst_code: athlete.runpark_code) unless athlete.fiveverst_code
    end

    remove_column :athletes, :runpark_code
  end
end
