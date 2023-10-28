# frozen_string_literal: true

class AddInformedColumn < ActiveRecord::Migration[7.0]
  def change
    add_column :results, :informed, :boolean, default: false, null: false
    add_column :volunteers, :informed, :boolean, default: false, null: false
  end
end
