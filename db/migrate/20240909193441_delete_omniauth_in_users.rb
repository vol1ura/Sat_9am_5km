# frozen_string_literal: true

class DeleteOmniauthInUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :users, bulk: true do |t|
      t.remove :uid, :provider, type: :string
    end
  end
end
