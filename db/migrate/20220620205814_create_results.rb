class CreateResults < ActiveRecord::Migration[7.0]
  def change
    create_table :results do |t|
      t.integer :position
      t.time :total_time
      t.integer :role, default: 0
      t.references :activity, null: false, foreign_key: true
      t.references :athlete, foreign_key: true
    end
  end
end
