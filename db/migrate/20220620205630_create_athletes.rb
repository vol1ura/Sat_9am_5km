class CreateAthletes < ActiveRecord::Migration[7.0]
  def change
    create_table :athletes do |t|
      t.string :name
      t.string :parkrun_id, index: true
      t.boolean :male

      t.timestamps
    end
  end
end
