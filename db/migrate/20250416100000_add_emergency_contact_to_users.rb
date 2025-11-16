# frozen_string_literal: true

class AddEmergencyContactToUsers < ActiveRecord::Migration[8.0]
  def change
    change_table :users, bulk: true do |t|
      t.string :emergency_contact_name
      t.string :emergency_contact_phone
    end
  end
end
