# frozen_string_literal: true

class AddTelegramIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :telegram_id, :bigint
    add_column :users, :telegram_user, :string
    add_index :users, :telegram_id, unique: true
  end
end
