# frozen_string_literal: true

class ImproveIndexForCountriesOnCode < ActiveRecord::Migration[8.0]
  def change
    remove_index :countries, :code, unique: true
    add_index :countries, :code, unique: true, include: [:id]
  end
end
