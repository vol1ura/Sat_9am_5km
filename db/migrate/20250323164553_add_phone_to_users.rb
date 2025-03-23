# frozen_string_literal: true

class AddPhoneToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :phone, :string
  end
end
