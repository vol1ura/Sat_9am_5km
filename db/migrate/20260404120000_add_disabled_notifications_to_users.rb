# frozen_string_literal: true

class AddDisabledNotificationsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :disabled_notifications, :text, array: true, default: [], null: false
  end
end
