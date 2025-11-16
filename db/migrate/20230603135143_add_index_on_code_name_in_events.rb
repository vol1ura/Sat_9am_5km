# frozen_string_literal: true

class AddIndexOnCodeNameInEvents < ActiveRecord::Migration[7.0]
  def change
    add_index :events, :code_name, unique: true
  end
end
