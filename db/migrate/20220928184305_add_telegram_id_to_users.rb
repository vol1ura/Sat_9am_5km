# frozen_string_literal: true

class AddTelegramIdToUsers < ActiveRecord::Migration[7.0]
  def change
    change_table :users, bulk: true do |t|
      t.column :telegram_id, :bigint
      t.column :telegram_user, :string
      t.index :telegram_id, unique: true
    end
  end
end
