# frozen_string_literal: true

class MakeEmailAndPasswordOptionalForUsers < ActiveRecord::Migration[8.0]
  def up
    change_table :users, bulk: true do |t|
      t.change_null :email, true
      t.change_null :encrypted_password, true
      t.change_default :email, from: '', to: nil
      t.change_default :encrypted_password, from: '', to: nil
      t.remove_index :auth_token
      t.index :auth_token, unique: true
    end
  end

  def down
    change_table :users, bulk: true do |t|
      t.change_null :email, false
      t.change_null :encrypted_password, false
      t.change_default :email, from: nil, to: ''
      t.change_default :encrypted_password, from: nil, to: ''
    end
  end
end
