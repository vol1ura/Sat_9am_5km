# frozen_string_literal: true

class AddOmniauthToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :users, bulk: true do |t|
      t.column :provider, :string
      t.column :uid, :string
    end
  end
end
