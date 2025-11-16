# frozen_string_literal: true

class AddAuthTokenToUsers < ActiveRecord::Migration[8.0]
  def change
    change_table :users, bulk: true do |t|
      t.string :auth_token
      t.datetime :auth_token_expires_at
      t.index :auth_token
    end
  end
end
