# frozen_string_literal: true

class AddFavoriteEventIdsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :favorite_event_ids, :bigint, array: true, default: [], null: false
  end
end
