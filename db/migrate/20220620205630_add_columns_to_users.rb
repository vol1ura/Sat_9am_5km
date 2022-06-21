class AddColumnsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :parkrun_id, :string
    add_index :users, :parkrun_id, unique: true
    add_column :users, :male, :boolean
    add_column :users, :role, :integer
  end
end
