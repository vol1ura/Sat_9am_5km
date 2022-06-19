class CreateActivities < ActiveRecord::Migration[7.0]
  def change
    create_table :activities do |t|
      t.date :date

      t.timestamps
    end
  end
end
