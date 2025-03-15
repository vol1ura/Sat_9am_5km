# frozen_string_literal: true

class CreateFriendships < ActiveRecord::Migration[7.1]
  def change
    create_table :friendships do |t|
      t.references :athlete, null: false, foreign_key: true
      t.references :friend, null: false, foreign_key: { to_table: :athletes }
      t.timestamps
    end

    add_index :friendships, %i[athlete_id friend_id], unique: true
    remove_index :friendships, :athlete_id # index is redundant as index_friendships_on_athlete_id_and_friend_id covers it
  end
end
