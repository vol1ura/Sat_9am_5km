class AddIndexOnAthletesNames < ActiveRecord::Migration[7.0]
  def up
    enable_extension :pg_trgm
    add_index :athletes, :name, opclass: :gist_trgm_ops, using: :gist
  end

  def down
    remove_index :athletes, :name
    disable_extension :pg_trgm
  end
end
