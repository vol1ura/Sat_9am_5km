# frozen_string_literal: true

class AddForeignKeysConstraints < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :athletes, :clubs
    remove_foreign_key :athletes, :users
    remove_foreign_key :results, :athletes
    add_foreign_key :athletes, :clubs, on_delete: :nullify
    add_foreign_key :athletes, :users, on_delete: :nullify
    add_foreign_key :results, :athletes, on_delete: :nullify
  end
end
