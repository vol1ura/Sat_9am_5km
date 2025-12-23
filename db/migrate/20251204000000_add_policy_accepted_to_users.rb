# frozen_string_literal: true

class AddPolicyAcceptedToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :policy_accepted, :boolean, default: false, null: false
  end
end
