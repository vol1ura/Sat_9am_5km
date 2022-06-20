class CreateResults < ActiveRecord::Migration[7.0]
  def change
    create_table :results do |t|
      t.time :total_time
      t.references :activity, null: false, foreign_key: true
      t.references :athlete, null: false, foreign_key: true
    end
  end
end
