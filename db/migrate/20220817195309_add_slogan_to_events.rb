class AddSloganToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :slogan, :string
  end
end
