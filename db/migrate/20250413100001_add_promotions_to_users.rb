# frozen_string_literal: true

class AddPromotionsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :promotions, :string, array: true, default: [], null: false
    add_index :users, :promotions, using: :gin
  end
end
