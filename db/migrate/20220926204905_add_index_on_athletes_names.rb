class AddIndexOnAthletesNames < ActiveRecord::Migration[7.0]
  def change
    add_index :athletes, :name, opclass: :gist_trgm_ops, using: :gist
  end
end
