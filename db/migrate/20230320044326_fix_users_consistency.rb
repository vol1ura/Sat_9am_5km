# frozen_string_literal: true

class FixUsersConsistency < ActiveRecord::Migration[7.0]
  def change
    change_column_null :users, :first_name, false
    change_column_null :users, :last_name, false
  end
end
