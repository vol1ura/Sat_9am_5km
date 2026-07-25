# frozen_string_literal: true

class AddPrivacyControls < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :distribution_consent, :boolean, default: false, null: false
    add_column :athletes, :hidden_profile, :boolean, default: false, null: false

    execute <<~SQL.squish
      UPDATE athletes SET hidden_profile = true WHERE user_id IS NOT NULL
    SQL
  end

  def down
    remove_column :athletes, :hidden_profile
    remove_column :users, :distribution_consent
  end
end
