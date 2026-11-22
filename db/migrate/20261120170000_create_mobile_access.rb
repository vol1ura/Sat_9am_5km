# frozen_string_literal: true

class CreateMobileAccess < ActiveRecord::Migration[8.1]
  def change
    create_table :mobile_pairing_codes do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.string :code_digest, null: false
      t.datetime :expires_at, null: false
      t.datetime :consumed_at
      t.integer :failed_attempts, null: false, default: 0
      t.timestamps
    end

    add_index :mobile_pairing_codes, %i[user_id expires_at]

    create_table :mobile_sessions do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.string :token_digest, null: false
      t.string :device_name
      t.datetime :expires_at, null: false
      t.datetime :last_used_at
      t.datetime :revoked_at
      t.timestamps
    end

    add_index :mobile_sessions, :token_digest, unique: true
    add_index :mobile_sessions, %i[user_id revoked_at]
    add_index :activities, :token, unique: true, where: 'token IS NOT NULL'
  end
end
