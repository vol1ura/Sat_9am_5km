# frozen_string_literal: true

class RequireCountryOnUsers < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :users, :countries
    change_column_null :users, :country_id, false
    add_foreign_key :users, :countries
  end
end
