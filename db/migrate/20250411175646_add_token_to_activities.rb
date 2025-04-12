# frozen_string_literal: true

class AddTokenToActivities < ActiveRecord::Migration[8.0]
  def change
    add_column :activities, :token, :string
  end
end
