# frozen_string_literal: true

class AddPrivacyControls < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :distribution_consent, :boolean, default: false, null: false
    add_column :athletes, :hidden_profile, :boolean, default: false, null: false
  end
end
